;;; convert-links.el --- convert logseq links to org-id links -*- lexical-binding: t; -*-

(setq logseq/id-regexp "[0-9a-f]\\{8\\}-\\(?:[0-9a-f]\\{4\\}-\\)\\{3\\}[0-9a-f]\\{12\\}")
(setq logseq/id-spec-regexp (concat "=id:: " logseq/id-regexp "=\\( \\|\n\\)"))
(setq logseq/filelink-target-regexp "[^]]*")
(setq logseq/alias-regexp "^alias:: \\(.*?\\)$")

(defun logseq/--get-id-part (match)
  ;; check if it's an id link
  (if (string-match logseq/id-regexp match)
      (substring-no-properties (match-string 0 match))
    ;; if not, check if it's a file link
    (when (string-match logseq/filelink-regexp match)
      (substring-no-properties (match-string 1 match)))))

(defun logseq/--convert-id-links-in-file (file hmap)
  "Generate org-ids in FILE, and return the association with their contexts.
First, convert the file itself into an org-roam node; then, remove logseq
'id::'s and convert the headlines they apply to into org-roam nodes (by
assigning an org id).
Add the associations to HMAP. For file nodes, associate the page title with
the node's id. For headline nodes, associate the replaced logseq id with the
node id."
  (find-file file)
  (goto-char 0)
  ;; convert the file itself into a node
  (re-search-forward "#\\+title: \\(.*\\)$")
  (let* ((title (substring-no-properties (match-string 1)))
         (id (org-id-get-create)))
    (puthash title id hmap)
    (if (re-search-forward logseq/alias-regexp nil t)
        (let ((aliases (split-string (match-string-no-properties 1) ", *")))
          (message "%s" aliases)
          (dolist (alias aliases) (puthash alias id hmap))))
    ;; search for logseq ids
    (while (re-search-forward logseq/id-spec-regexp nil t)
      (let ((match (substring-no-properties (match-string 0))))
        ;; delete logseq id
        (replace-match "" nil nil)
        (let ((id-part (logseq/--get-id-part match)))
          ;; key is the old logseq id; value is newly created org id for this entry
          (puthash id-part (org-id-get-create) hmap)))))
  (save-buffer)
  hmap)

(defun logseq/convert-id-links (graphdir)
  ;; (eq "a" "a") -> nil; (eql "a" "a") -> nil; (equal "a" "a") -> t
  (let ((hmap (make-hash-table :test 'equal)))
    (dolist (file (directory-files-recursively graphdir "org$"))
      (logseq/--convert-id-links-in-file file hmap))
    hmap))

(setq logseq/embed-regexp (concat "={{ *\\(embed\\) " logseq/id-regexp " *}}="))
(setq logseq/query-regexp (concat "={{ *\\(query\\) " logseq/id-regexp " *}}="))
(setq logseq/link-regexp (concat "\\[\\[file:((" logseq/id-regexp "))\\]\\[\\(.*\\)\\]\\]"))
(setq logseq/filelink-regexp
      (concat "\\[\\[file:\\(" logseq/filelink-target-regexp "\\)\\]\\]"))
(setq logseq/blockref-regexp (concat "((" logseq/id-regexp "))"))

(defun logseq/--replace-with-org-links-in-file (file hmap)
  "Replace Logseq link syntax in FILE with org-id links, based on the
associations in HMAP."
  (find-file file)
  (goto-char 0)
  (while (or (re-search-forward logseq/embed-regexp nil t)
             (re-search-forward logseq/query-regexp nil t)
             (re-search-forward logseq/link-regexp nil t)
             (re-search-forward logseq/filelink-regexp nil t)
             (re-search-forward logseq/blockref-regexp nil t))
    (let* ((match (substring-no-properties (match-string 0)))
           (match-data (match-data))
           (id-part (logseq/--get-id-part match))
           (node-struct (org-roam-node-from-id
                         (gethash id-part hmap))))
      (set-match-data match-data)
      (when node-struct
        ;; HACK: prevent org-roam-node-insert from reading a node from
        ;; user; instead just use our node
        (replace-match "" nil nil)
        (cl-letf (((symbol-function 'org-roam-node-read)
                   (lambda (&rest args) node-struct)))
          ;; ((symbol-function 'org-roam-node-formatted)
          ;; (lambda (node) (org-roam-node-title node))))
          (org-roam-node-insert)))
      (set-match-data match-data)
      (unless node-struct
        (replace-match (substring-no-properties
                        (or (match-string 1) "")) nil nil)
        (message (format "No node found for %s" match))))
    (goto-char 0))
  (save-buffer))

(defun logseq/replace-with-org-links (graphdir hmap)
    (dolist (file (directory-files-recursively graphdir "org$"))
      (logseq/--replace-with-org-links-in-file file hmap)))

;; (let* ((file "~/scratchdir/logseq_main_/pages/linux/arch/installation.org")
;;        (table (logseq/--convert-id-links-in-file file (make-hash-table))))
;;   (org-roam-db-sync t)
;;   (logseq/--replace-with-org-links-in-file file table))

(defun logseq/convert-links (graphdir)
  (let ((table (logseq/convert-id-links graphdir))
        (org-roam-directory graphdir))
    (org-roam-db-sync t)
    (logseq/replace-with-org-links graphdir table)))

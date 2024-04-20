;;; remove-custom-ids.el --- Remove CUSTOM_ID property assigned by pandoc org parser -*- lexical-binding: t; -*-

(defun logseq/remove-custom-ids (graphdir)
  (dolist (file (directory-files-recursively graphdir "org$"))
    (with-temp-file file
      (insert-file-contents file)
      (org-delete-property-globally "CUSTOM_ID"))))

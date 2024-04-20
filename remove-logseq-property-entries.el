;;; remove-logseq-property-entries.el --- Remove logseq property subtrees -*- lexical-binding: t; -*-

;; this will write to your kill ring!
(defun logseq/remove-logseq-property-entries (graphdir)
  "In the 'properties' shell script, we moved each logseq property into a block
to prevent pandoc's org parser from messing them up. Now that we don't need the
properties anymore, we delete them."
  (org-map-entries #'org-cut-subtree
                   "!property-deleteme!"
                   (directory-files-recursively graphdir "org$")))

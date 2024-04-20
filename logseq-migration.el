;;; logseq-migration.el --- elisp processing of converted logseq graph -*- lexical-binding: t; -*-

(load-file "convert-links.el")
(load-file "remove-custom-ids.el")
(load-file "remove-logseq-property-entries.el")
(let ((graphdir "path/to/my/graph/pages_")) ;; change as needed
  (logseq/remove-custom-ids graphdir)
  (logseq/convert-links graphdir)
  (logseq/remove-logseq-property-entries graphdir))
  ;; comment out the below line if you don't want to delete logseq properties

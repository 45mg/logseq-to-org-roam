This is a set of rough scripts that I used to help me convert my Logseq graph to org-roam. Use at your own risk, and please read the code before you use it.

As I no longer have any use for this code (having finished converting my Logseq graph), I will not be maintaining it in any way. If you need any improvements, you'll have to fork the repo and work on them yourself.

# Supported
- conversion of Logseq's weird markdown dialect to org-mode: pandoc does most of the actual conversion, but various scripts are needed to massage Logseq's markdown into something it can understand
- converting links: Logseq links/tags are converted to org-roam links; page aliases are supported

# Not Supported
- queries and embeds
- images and other file assets
- journals (see Instructions below)
- many other things i didn't think of, no doubt

# Requirements
Tested with:

```
pandoc 3.1.9
emacs 29.1
```
In theory newer versions should work.

# Instructions
- Clone this repo.
- Backup your existing logseq graph folder, just in case.
- These scripts are designed to run on the 'pages' folder of your graph; decide what you're going to do with your journals. I combined them all into a single page like this:
``` sh
for file in journals/*; do
    cat "$file" >> pages/journals.md
done
```
- run the shell script `logseq-migration` on your graph's `pages` folder:
  `path/to/this/repo/logseq-migration pages`
  This will create a folder named `pages_` containing converted org-mode files; see the comments in `logseq-migration` for details.
- in Emacs, run the code in `logseq-migration.el`. This will convert links and do some other post-processing.

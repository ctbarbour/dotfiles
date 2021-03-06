;; Thanks to Eric Merritt (http://blog.erlware.org/2012/05/15/getting-flymake-and-rebar-to-play-nice/)
(defun ebm-find-rebar-top-recr (dirname)
  (let* ((project-dir (locate-dominating-file dirname "rebar.config")))
    (if project-dir
	(let* ((parent-dir (file-name-directory (directory-file-name project-dir)))
	       (top-project-dir (if (and parent-dir (not (string= parent-dr "/")))
				    (ebm-find-rebar-top-recr parent-dir)
				  nil)))
	  (if top-project-dir
	      top-project-dir
	    project-dir))
      project-dir)))

(defun ebm-find-rebar-top ()
  (interactive)
  (let* ((dirname (file-name-directory (buffer-file-name)))
	 (project-dir (ebm-find-rebar-top-recr dirname)))
    (if project-dir
	project-dir
      (erlang-flymake-get-app-dir))))

(defun ebm-directory-dirs (dir name)
  "Find all directories in DIR."
  (unless (file-directory-p dir)
    (error "Not a directory `%s'" dir))
  (let ((dir (directory-file-name dir))
	(dirs '())
	(files (directory-files dir nil nil t)))
    (dolist (file files)
      (unless (member file '("." ".."))
	(let ((absolute-path (expand-file-name (concat dir "/" file))))
	  (when (file-directory-p absolute-path)
	    (if (string= file name)
		(setq dirs (append (cons absolute-path
					 (ebm-directory-dirs absolute-path name))
				   dirs))
	      (setq dirs (append
			  (ebm-directory-dirs absolute-path name)
			  dirs)))))))
    dirs))

(defun ebm-get-deps-code-path-dirs ()
  (ebm-directory-dirs (ebm-find-rebar-top) "ebin"))

(defun ebm-get-deps-include-dirs ()
  (ebm-directory-dirs (ebm-find-rebar-top) "include"))

(fset 'erlang-flymake-get-code-path-dirs 'ebm-get-deps-code-path-dirs)
(fset 'erlang-flymake-get-include-dirs-function 'ebm-get-deps-include-dirs)


(provide 'rebar-config)

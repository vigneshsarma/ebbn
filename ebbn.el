;;; ebbn.el --- Emacs, Better Buffer Names

;; Copyright (C) 2012 Vignesh Sarma <vignesh.sarma@gmail.com>

;; Author: Vignesh Sarma <vignesh.sarma@gmail.com>
;; URL: http://github.com/vigneshsarma/ebbn
;; Version: 0.1.1
;; Keywords: buffers file
;; Package-Requires: ((s "1.4.0"))

;; This file is not part of GNU Emacs.

;; This file is free software...
;; Variables
;;     ebbn/ignore-folder-names
;;         The folder names in this list will be ignored when deciding the new name for the buffer.
;;     ebbn/rename-only-if-there-is-duplication
;;         If set to true buffers will be renamed only if there is another file buffer with the same name.

(require 's)

(setq ebbn/ignore-folder-names (list "api"))
(setq ebbn/file-alies '(("api"  ":A:") ("candidate"  ":Can:") ("opening"  ":Op:")
			    ("models.py"  "Mpy") ("tests.py"  "Tpy") ("resources.py"  "Rpy")))
(setq ebbn/rename-only-if-there-is-duplication nil)

(defun file-buffer? (bf)
  (if (buffer-file-name bf) bf nil))

(defun get-file-buffers ()
  (remove-if nil (mapcar 'file-buffer? (buffer-list))))

;; buffer rename
(defun buffer-rename (bf new-name)
  (setq tmp-str (current-buffer))
  (set-buffer (get-buffer bf))
  (rename-buffer new-name)
  (set-buffer tmp-str))

(defun parent-file-name (xs)
  (let ((name (if xs (car (cdr xs)) nil)))
    (if (member name ebbn/ignore-folder-names)
	(parent-file-name (cdr xs))
      name)))

(defun alies (f-name)
  (or (cadr (assoc f-name ebbn/file-alies)) f-name))

(defun ebbn/find-better-name (bf)
  (let ((bf-path-list (reverse (s-split "/" (buffer-file-name bf)))))
    (format "%s<%s>" (alies (car bf-path-list)) (alies (parent-file-name bf-path-list)))))

;; func to rename buffer
(defun ebbn/better-buffer-name (&optional buffer)
  (let* ((bf (if buffer (get-buffer buffer) (current-buffer)))
	 (bfs (get-file-buffers))
	 (bf-name (car (reverse (s-split "/" (buffer-file-name bf)))))
	 (same-file-name? (lambda (bf-tmp)
			    (s-equals? bf-name
				       (car (reverse (s-split "/" (buffer-file-name bf-tmp))))))))
        (if ebbn/rename-only-if-there-is-duplication
	    (let ((files-with-same-name (remove-if-not same-file-name? bfs)))
	      (mapcar (lambda (bf-tmp) (buffer-rename bf-tmp (ebbn/find-better-name bf-tmp))) files-with-same-name))
	  (buffer-rename bf (ebbn/find-better-name bf)))))

(defun ebbn/complete-rename ()
  (mapc 'ebbn/better-buffer-name (get-file-buffers)))
;; (add-hook 'find-file-hook 'ebbn/better-buffer-name)
(provide 'ebbn)

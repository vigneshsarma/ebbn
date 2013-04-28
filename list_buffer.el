(require 's)

;; regex for numeric buffer-name ends
(setq ebbn/numbered-buffers "\\([^<]+\\)<\\([^>]+\\)>")

(setq ebbn/ignore-folder-names (list "api"))

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

(defun get-acceptable-parent-name (bf)
  (let ((path-list (reverse (s-split "/" (buffer-file-name bf)))))
    (parent-file-name path-list)))

(defun give-better-name (&optional buffer)
  (let* ((bf (if buffer (get-buffer buffer) (current-buffer)))
	 (bfs (get-file-buffers))
	 (bf-name (car (reverse (s-split "/" (buffer-file-name bf)))))
	 (same-file-name? (lambda (a bf-tmp) (or a (s-equals? bf-name
							      (car (reverse (s-split "/" (buffer-file-name bf-tmp)))))))))
    (if (reduce same-file-name? bfs :initial-value nil)
	(buffer-rename bf (format "%s<%s>" bf-name (get-acceptable-parent-name bf))) nil)))

;; (add-hook 'find-file-hook 'give-better-name)
;; func to rename buffer
(defun rename-buffer-when-numericed (bf)
  (if (and (setq bf-match (s-match ebbn/numbered-buffers (buffer-name bf)))
	   (s-numeric? (if (stringp (third bf-match))
			   (third bf-match)
			 "")))
      (buffer-rename bf (format "%s<%s>" (second bf-match)  (get-acceptable-parent-name bf)))
    nil))

(defun ebbn/complete-rename ()
  (mapc (function rename-buffer-when-numericed) (get-file-buffers)))

(defun flatten (lst)
  (cond ((null lst) nil)
        ((atom lst) (list lst))
        (t (append (flatten (car lst))
                   (flatten (cdr lst))))))

(defun str (&rest rest)
  (let ((str (mapconcat 'identity (flatten rest) " ")))
    (substring str 0 (length str))))

(defun ts (&rest s)
  (str (format-time-string "%Y-%m-%d %H:%M:%S" (current-time))
       s))

(defun chomp (str)
  (if (and (stringp str) (string-match "\r?\n$" str))
      (replace-match "" t nil str)
    str))

(defun trim (str)
  (flet ((tr (regexp str)
             (if (and (stringp str) (string-match regexp str))
                 (replace-match "" t nil str)
               str)))
    (tr "^ +" (tr " +$" str))))

(defun line-at-point ()
  (save-excursion
    (beginning-of-line)
    (push-mark)
    (end-of-line)
    (buffer-substring (mark) (point))))

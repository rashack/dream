(require 'cl)

;; load auxiliary functions
(load-file "aux-funs.el")

(defconst client-process-name "*dyalog-process*")
(defsubst client-process () (get-process client-process-name))
(defconst client-buffer-name "*dyalog-client*")

(defvar dyalog-remote-mode-hook nil)
(defvar dyalog-remote-mode-map
  (let ((map (make-keymap)))
    (define-key map "\C-x\C-e" 'client-send-line)
    map)
  "Keymap for Dyalog APL remote mode")

(defvar dyalog-remote-mode-font-lock-keywords
  (list
   '("^\\*\\*\\*.*$" . font-lock-comment-face)
   '("\\*\\*\\*" . font-lock-warning-face)))

(defvar dyalog-mode-res-prompt "      ")

;;(defsubst client-buffer ()
(defun client-buffer ()
  (let ((buffer (get-buffer client-buffer-name)))
    (if buffer
        buffer
      (init-dyalog-remote-buffer))))

(defun insert-end-of-buffer (line)
  (with-current-buffer (client-buffer)
    (save-excursion
      (end-of-buffer)
      (when (not (looking-at "^"))
        (insert"\n"))
      (insert line))))

(defun client-send-line ()
  (interactive)
  (let ((line (line-at-point)))
    (insert-end-of-buffer (str dyalog-mode-res-prompt (trim line)))
    (client-send-string line)))

(defun dyalog-remote-mode ()
  "Major mode for a Dyalog APL client buffer"
  (interactive)
  (kill-all-local-variables)
  (use-local-map dyalog-remote-mode-map)
  (setq major-mode 'dyalog-remote-mode)
  (set (make-local-variable 'font-lock-defaults)
       '(dyalog-remote-mode-font-lock-keywords))
  (setq mode-name "dyalog-remote")
  (run-hooks 'dyalog-remote-mode-hook))

(provide 'dyalog-remote-mode)
(require 'dyalog-remote-mode)



;; open-network-stream
(defun client-open (host port)
  (make-network-process :name client-process-name
                        :host host
                        :service port
                        :nowait nil ; why can't this be t?
                        :coding 'utf-8
                        :sentinel #'client-notify-connect
                        :filter 'handle-reply
                        :filter-multibyte t
                        :buffer client-buffer-name)
  (sit-for 1))

(defun connect-to-dyalog (port)
  (init-dyalog-remote-buffer)
  (client-open 'local port))

(defun client-close ()
  (delete-process (client-process)))

(defun client-send-stringln (str)
  (process-send-string (client-process) (concat str "\n")))
(defun client-send-string (str)
  (interactive)
  (process-send-string (client-process) str))

(defun init-dyalog-remote-buffer ()
  (let ((buffer (get-buffer-create client-buffer-name)))
    (with-current-buffer buffer
      (dyalog-remote-mode)
      (end-of-buffer))
    buffer))

(defun client-notify-connect (&rest args)
  (let ((msg (format "Connection message [%s]" (mapcar #'chomp args))))
    (message msg)
    (insert-client-buffer-end "*** " msg "\n")))

(defun handle-reply (process content)
  (push-mark)
  (insert-client-buffer-end content))

(defun insert-client-buffer-end (&rest rest)
  (with-current-buffer (client-buffer)
    (goto-char (point-max))
    (when (not (looking-at "^"))
      (insert"\n"))
    (insert (str rest))))




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; examples below

;;(set-process-coding-system (client-process) 'utf-8 'utf-8)
(process-list)

(client-close)
(connect-to-dyalog 5005)

(client-send-string "t")
(client-send-stringln "2+5")
(client-send-stringln "å")
(client-send-string "åäö")
(client-send-string "ts")
(client-send-string "abc")
(client-send-string "t←1+3")
(client-send-string "t←1+5")
(client-send-string "1 2 3+5")
(client-send-string "2 2⍴⍳4")

(client-send-string "dec2hex←{⍉'0123456789ABCDEF'[⎕IO+((⌈⌈/16⍟,⍵)⍴16)⊤⍵]}")

;; )copy "C:\Program Files (x86)\Dyalog\Dyalog APL 12.1 Classic\ws\Conga" DRC

;; ⎕←⎕se.SALT.Load 'z:\exec-server'
;; ⎕←⎕se.SALT.Load '/home/kjell/Downloads/exec-server.dyalog'
;; execServer.start & 5005

;; CDONE←1
;; DRC.Close 'XSrv'

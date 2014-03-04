((js2-mode . ((js2-basic-offset . 2)))
 (scss-mode . ((css-indent-offset . 2)
               (scss-compile-at-save . nil)))
 (go-mode . ((eval . (let* ((local-go-path (concat (file-name-directory (or load-file-name buffer-file-name)) "vendor"))
                        (current-go-path (getenv "GOPATH")))
                   (if (not current-go-path)
                       (setenv "GOPATH" local-go-path)
                     (unless (string-match local-go-path current-go-path)
                       (setenv "GOPATH" (concat current-go-path ":" local-go-path)))))))))

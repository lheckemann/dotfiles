(defun jq-on-change (begin end prev-len) "" nil
  (write-region (point-min) (point-max) "/scratch/query.jq" nil nil nil nil)
  (shell-command "jq -f /scratch/query.jq </scratch/activity.json" "*jq output*" "*jq output*"))
(defun enable-jq-on-change () ""
  (add-hook 'after-change-functions 'jq-on-change nil t))

(define-module (simpsim metas))

(define-public (meta-git-current-branch)
  "$(git branch --show-current)")

(define-public (meta-git-head-commit)
  "$(git rev-parse HEAD)")

(define-public (meta-date)
  "$(date)")

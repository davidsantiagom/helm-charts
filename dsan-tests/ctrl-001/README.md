
Deploy the job and check logs:

% kubectl -n vcl-t001-dev logs job/test-intra-allow
CONTROL 1 (intra) PASSED — HTTP 200 from http://echo.vcl-t001-dev.svc.cluster.local:80/

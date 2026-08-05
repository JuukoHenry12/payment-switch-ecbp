# ECBP Test Framework (Python)

```bash
poetry install
poetry run pytest ecbp_tests/api_tests
poetry run pytest ecbp_tests/e2e_tests --headed
```
## Known limitations
- WebKit browser has a missing-DLL issue on native Windows (brotlicommon.dll,
  javascriptcore.dll, and others). Chromium and Firefox are unaffected.
  E2E tests target Chromium by default; revisit WebKit only if cross-browser
  coverage becomes a requirement.

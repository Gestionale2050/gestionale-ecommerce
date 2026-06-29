# EXISTENZA Recovery Artifact — QUARANTINE

**Status:** `INVALID / DO_NOT_EXECUTE`

## Authorized target

- File name: `Invoke-EXISTENZA-Mega-Recovery-v1_0_0.ps1`
- Expected SHA-256: `300c968d100be3088eee820a9a8ba7a0e2fcd6aece10bae6f0ef37d8fcfa41dc`

## Observed results

### Historical uncompressed fragment test

- Commit tested: `96d8648a41f3b7dbdcd45e00a269302561f5dac2`
- Reconstructed SHA-256: `75bf15b42ac5871ba4673e72429323521c42c48531d0b33ab6a5153dd58206e0`
- Result: mismatch; candidate deleted.

### Concatenated GZip payload test

- Payload parts downloaded: 3
- Base64: valid
- DEFLATE: decompressed successfully
- Output size: `154242` bytes
- Reconstructed SHA-256: `d18f355c4897a46a3b794579b37ace882a94e2d02571778be7dd8f1b4d1d0ca9`
- Result: mismatch; no final file retained.

## Decision

Do not:

- replace the expected hash with an observed mismatch;
- disable SHA-256 verification;
- execute the reconstructed candidate;
- treat successful PowerShell parsing as authorization;
- repair the GZip trailer manually and trust the result.

The payload remains preserved only as evidence of the failed transfer. The downloader has been disabled and now aborts immediately.

## Required recovery path

Retrieve the original source from a trusted source, or create a new script as a new version. A newly generated script must receive:

1. a new immutable version identifier;
2. its own SHA-256 computed from the exact source bytes;
3. a local PowerShell parser check;
4. a separate transfer-integrity test;
5. no reuse of the invalid v1.0.0 authorization claim.

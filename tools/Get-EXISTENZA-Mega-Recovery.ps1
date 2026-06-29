#requires -Version 5.1
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

throw @"
ARTEFATTO IN QUARANTENA — NON UTILIZZARE.

Il payload pubblicato in questo branch non ricostruisce il file autorizzato.

Hash autorizzato atteso:
300c968d100be3088eee820a9a8ba7a0e2fcd6aece10bae6f0ef37d8fcfa41dc

Hash ottenuto dal payload GZip:
d18f355c4897a46a3b794579b37ace882a94e2d02571778be7dd8f1b4d1d0ca9

Il recupero resta bloccato finché non viene ritrovato o rigenerato da zero un sorgente verificato.
Non sostituire l'hash atteso. Non eseguire il candidato ricostruito.
Consultare tools/EXISTENZA_RECOVERY_QUARANTINE.md.
"@

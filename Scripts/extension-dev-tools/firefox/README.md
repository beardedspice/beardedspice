## build-firefox-extension.sh
`build-firefox-extension.sh` is an enhanced version of "cfx xpi". It does the following:

1. Runs `cfx xpi` to pack the extension.
2. If the current directory contains `install.rdf`, `minVersion` and `maxVersion`
   are copied to the "install.rdf" file inside the XPI, and the original install.rdf
   is replaced with this new install.rdf inside the XPI file
   (the previous one is moved to `install.rdf.bak`).
3. If an environment variable "`XPIPEM`" is set, t
   The XPI file is signed using the `codesigning.pem`. You can set the pem path via the
   `XPIPEM` environment variable. If the pem file does not exist, the XPI is not signed.

The PEM file should contain the following files:

- Your private key.
- Your certificate.
- All other certificates in the certificate chain, up to the root certificate.
  The root certificate is optional, it will not be included in the final xpi file,
  because it should already be included by default in the browser.

For more information, see

- [Signing Firefox extensions with Python and M2Crypto]
  (https://adblockplus.org/blog/signing-firefox-extensions-with-python-and-m2crypto) (blog post by Wladimir Palant).
- [Signing Firefox add ons with a StartSSL Object Code Signing certificate]
  (https://github.com/nmaier/xpisign.py/wiki/Signing-Firefox-add-ons-with-a-StartSSL-Object-Code-Signing-certificate)
  (wiki of xpisign.py)

### Generation of PEM file
1. Generate private key and certificate signing request (CSR).  
   **Note: StartCom will *ignore* all fields (such as CN, E, O) except for the public key
   in the CSR. All certificate details (common name, email address, locality, etc.) are
   directly taken from your StartCom Identity card (created during your identity verification.)**

        openssl req -nodes -newkey rsa:2048 -keyout codesigning.key -out codesigning.csr

        # OPTIONAL: Add a pass phrase to your private key
        openssl rsa -in codesigning.key -des3 -out codesigning2.key
        # Replace the password-free key with the password-protected key:
        mv codesigning2.key codesigning.key

        # Avoid loss of private key by marking it read-only (without it, you cannot use your certificate for signing)
        chmod -w codesigning.key

   A 2048-bit RSA key is secure enough for the next decade in most cases. If you're dealing with assets of a very high
   value, consider using 3072 or 4096-bit keys (at the cost of runtime performance).
   See also: [Why not use larger cipher keys?](http://security.stackexchange.com/questions/25375/why-not-use-larger-cipher-keys)

2. Send CSR to a Certificate Authority to get a certificate (.crt file).
3. Get the CA bundle from your CA (in PEM format). For example (StartCom):

        wget https://www.startssl.com/certs/sub.class2.code.ca.pem

4. Concatenate all files to the final file:

        cat codesigning.crt sub.class2.code.ca.pem codesigning.key > codesigning.pem
        
        # OPTIONAL: Export to PFX file (not needed for Firefox code signing, but necessary for
        #           signing DLLs, EXE, etc. using Microsoft's signtool.exe
        openssl pkcs12 -in codesigning.pem -export -out codesigning.pfx

## Example
```
# Sign add-on in /tmp/test/ using the default certificate and private key pair (if set).
build-firefox-extension.sh /tmp/test
# Sign add-on in a subdirectory dist/firefox/ using the cert and key in certs/codesigning.pem.
XPIPEM=certs/codesigning.pem build-firefox-extension.sh dist/firefox
```

## Troubleshooting
After signing the file, the value of "Organization Name" or "Common Name" will be displayed at the Add-on install dialog.
If you still see "Author not verified", then something went wrong.

To debug your issue, look in the browser's Error console (Ctrl + Shift + J). Make sure that "JS -> Log" is enabled.  
The next section shows how I found and debugged my "Author not verified" issue.

### Signature Verification Error
After getting a **code signing** (*not* SSL) certificate from [StartCom](https://www.startssl.com/), I signed
my XPI. When I opened the extension in Firefox 25, I saw the following error in my console:

> "Signature Verification Error: the signature on this .jar archive is invalid because the digital signature
> (\*.RSA) file is not a valid signature of the signature instruction file (\*.SF)."

After hours of debugging (browsing Firefox's source code, gdb and Wireshark), I found the culprit. **It turns
out that there's nothing wrong with my XPI file.** When Firefox queried the ocsp.startssl.com for the revocation
status of my certificate, "certStatus: unknown (2)" was returned by StartCom. Apparently, it takes a half day
before the certificate status is sent to all OCSP servers. Take a look StartCom's forum:
[Certificate OCSP Validation Failiure in Firefox](https://forum.startcom.org/viewtopic.php?f=15&t=2654).

If you're experiencing the same issue, go to `about:config` and set `security.OCSP.enabled` to `0`. This will
prevent Firefox from checking the certificate revocation status. Installation of signed extensions will also
be faster because the installation is no longer delayed by the OCSP request.

If you want to debug the OCSP request:

1. Start Wireshark, start the capture and apply the following filter:

        http.content_type contains "ocsp" and http.server contains "StartCom"
2. Start Firefox (in a new (temporary) profile to make sure that Firefox does not use a cached OCSP response:

        rm -r fftemp ; mkdir fftemp ; firefox -profile fftemp --no-remote /tmp/path/to/addon.xpi
3. *The installation dialog shows up, and it shows either "Author not verified" or "your name"*
4. Go back to Wireshark, and look at "Online Certificate Status Protocol" -> "responseBytes" -> "tbsResponseData" ->
   "responses" -> "SingleResponse" -> "certStatus". This field's value should be "good (0)".

## Dependencies
- [Add-on SDK](https://addons.mozilla.org/en-US/developers/docs/sdk/latest/dev-guide/tutorials/installation.html)
  to package the add-on (using the [`cfx tool`](https://addons.mozilla.org/en-US/developers/docs/sdk/latest/dev-guide/cfx-tool.html)).
- [7-zip](http://www.7-zip.org) for manipulating `install.rdf` (at step 2).
- [xpisign](https://github.com/nmaier/xpisign.py/) to sign the XPI file.

## External links
Much of this build script would be obsolete when the following bugs get fixed:

- [Bug 884924 - package.json should support minVersion in targetApplication](https://bugzilla.mozilla.org/show_bug.cgi?id=884924)
- [Bug 657494 - add XPI code-signing tools to 'cfx xpi --sign'](https://bugzilla.mozilla.org/show_bug.cgi?id=657494)

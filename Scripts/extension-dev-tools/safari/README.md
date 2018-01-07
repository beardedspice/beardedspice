Copyright Rob Wu <gwnRob@gmail.com> (https://robwu.nl/)  
Last modified: 30 december 2013

## File structure
* `update.plist` - to be placed on the server hosting the extension
* `*.safariextz` - the packed and signed extension
* `*.safariextension/` - The extension's files.

## Building (manually)
To build the extension, go to Safari:

1. Open the Develop menu (can be shown by opening `Preferences > Advanced` and check "Show Develop menu in menu bar")
2. [Menu item] "Develop"
3. [Menu item] "Show Extension builder"
4. [Button] "Add extension" and select the `*.safariextension` directory.
5. [Button] "Build extension"


## Building (automated, Linux/Mac)
1. Get xar-1.6.1.tar.gz from http://mackyle.github.com/xar/.
2. Create the xar binary:

        tar xf xar-1.6.1.tar.gz
        cd xar-1.6.1
        ./configure --disable-shared
        make
        mv src/xar ..
        cd ..
        rm -r xar-1.6.1

3. Put all required files in the `certs/` directory:
   - Download certificates from https://www.apple.com/certificateauthority/
    - `AppleWWDRCA.cer`
    
            wget https://developer.apple.com/certificationauthority/AppleWWDRCA.cer -OAppleWWDRCA.cer
    - `AppleIncRootCertificate.cer`

            wget https://www.apple.com/appleca/AppleIncRootCertificate.cer -OAppleIncRootCertificate.cer
    - `safari_extension.cer`
      Log in to https://developer.apple.com/account/safari/certificate/certificateList.action
      and download the certificate.
    - `key.pem`
      This was generated together with your CSR (see section "Certificate").
      
   If you are trying to automate the build steps for an existing extension, follow the following steps instead.
   This is advised, because there is a chance that one of the certificates have been modified since its initial
   creation.

        cd certs
        path/to/xar -f path/to/name.safariextz --extract-certs .
        mv cert00 safari_extension.cer
        mv cert01 AppleWWDRCA.cer
        mv cert02 AppleIncRootCertificate.cer

   The private key's location is only known to you. If you've got a PFX or P12 file, then you can use the
   following command to extract the private key:

        openssl pkcs12 -in safari_extension.pfx -nodes | openssl rsa -out key.pem

   If you wish to keep the `certs` directory in a different location, edit the shell script discussed
   below, and adjust the `certdir` variable (defaults to the `certs` directory at the same level of the shell script).

4. Now run the build script using `./build-safari-extension.sh path/to/name.safariextension`
5. Optional: Create a symlink to the shell script in a directory within your `$PATH`.  
   For example, if `~/bin/` is a directory listed in your `$PATH` environment variable, use
   `ln -s path/to/build-safari-extension.sh ~/bin/safariext-build`.  
   After doing that, you can easily build Safari extensions using `safariext-build path/to/name.safariextension`
   without having to carry around the files and developer certificates.
6. If you wish to (temporarily) use a different certificate directory for a specific project, set the `CERTDIR`
   environment variable to override the certdir set in the build script.  
   Example:

        CERTDIR=path/to/certs safariext-build path/to/name.safariextension


## Certificate
In order to build (or even test) a Safari extension, you need a certificate from Apple.

1. Create an Apple ID if not already done. After registering, visit 
   https://developer.apple.com/account/safari/certificate/certificateList.action
2. To get a certificate, you need to get a private key and a CSR (Certificate Signing Request) file.
   The following command creates `private_key.key` and `cer_sign_request.csr`:

        openssl req -nodes -newkey rsa:2048 -keyout private_key.key -out cer_sign_request.csr
        # You do NOT want to loose these files (esp. the private key): make it read-only.
        chmod -w private_key.key cer_sign_request.csr

3. Upload `cer_sign_request.csr` to Apple, and download the certificate (link at step 1).
4. *Optional*. Only necessary if you wish to use the Extension Builder GUI in Apple Safari.
   Install the certificate on your OS.
   My `.key` and `.csr` files were created on a different computer, so Safari did not accept
   my downloaded `safari_extension.cer` (because the corresponding private key was not found
   at the machine).  
   I solved this by creating a `.pem` file from my `.key` file, and generated a `.pfx` file
   (private key + certificate) from the `.pem` and `.cer` file. Commands used:

        # Create pem file from key
        (echo '-----BEGIN CERTIFICATE-----'; base64 safari_extension.cer; echo '-----END CERTIFICATE-----') > safari_extension.crt 
        # Create pfx file
        openssl pkcs12 -inkey private_key.key -in safari_extension.crt -export -out safari_extension.pfx

    The last command will prompt for a password. This password will be asked when you import the pfx file.

        Enter Export Password:
        Verifying - Enter Export Password:
    After creating the `.pfx` file, I copied it (securely!) to my Windows VM (which is running Safari).
    I installed the certificate (`.pfx`), and Safari finally recognized my certificate!

## Refreshing an expired certificate
Extension certificates issued by Apple expire after 1 year. Update your certificate as follows:

1. Submit the CSR file to Apple (may be the same as the one created at step 2 at the "Certificate" section).
2. Download `safari_extension.cer` from Apple.
3. Repeat step 3 of section "Building (automated, Linux/Mac)".

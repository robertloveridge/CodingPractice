# Adestra XML-RPC API with PHP

I'm going through some of my old help docs I'd written for teams whilst working at Adestra. Here's one I wrote on the Adestra API - using XML-RPC over HTTPS.

## How XML-RPC Works

XML-RPC is a protocol that lets you call remote methods using XML.

**Basic flow:**

 * Build an XML request
 * Send it via HTTP POST
 * Receive an XML response
 * Parse the result

## Getting Started

**API Endpoint**
https://app.adestra.com/api/xmlrpc

**Authentication**
Adestra uses HTTP Basic Authentication.

**Format**
```https://ACCOUNT:USERNAME:PASSWORD@app.adestra.com/api/xmlrpc```

**Example**
```https://myaccount:apiuser:password@app.adestra.com/api/xmlrpc```

## Making Your First Request

**XML Structure**

```xml
<?xml version="1.0"?>
<methodCall>
  <methodName>method.name</methodName>
  <params>
    <param>
      <value><string>example</string></value>
    </param>
  </params>
</methodCall>
```
### Example: Contact Search (PHP)

```php
<?php

require 'vendor/autoload.php';

use PhpXmlRpc\Client;
use PhpXmlRpc\Request;
use PhpXmlRpc\Value;

$account  = 'your_account';
$username = 'your_username';
$password = 'your_password';

$url = "https://$account:$username:$password@app.adestra.com/api/xmlrpc";

$client = new Client($url);

$request = new Request('contact.search', [
    new Value(1, 'int'),
    new Value([
        'email' => new Value('test@example.com', 'string')
    ], 'struct')
]);

$response = $client->send($request);

if ($response->faultCode()) {
    die('API Error: ' . $response->faultString());
}

$result = $response->value()->scalarval();

print_r($result);
```

## Understanding Requests and Parameters

**Method Format**

```object.action```

**Examples:**

 * contact.search
 * contact.insert
 * contact.update
 * email.send

## Parameter Types

| Type   | Description      |
| ------ | ---------------- |
| string | Text values      |
| int    | Integer values   |
| struct | Key-value object |
| array  | List of values   |

**Example XML Request**

```xml
<methodCall>
  <methodName>contact.search</methodName>
  <params>
    <param>
      <value><int>1</int></value>
    </param>
    <param>
      <value>
        <struct>
          <member>
            <name>email</name>
            <value><string>test@example.com</string></value>
          </member>
        </struct>
      </value>
    </param>
  </params>
</methodCall>
```

## Understanding Responses

Responses are returned as XML but converted into PHP arrays/objects by the library.

**Example XML Response**

```xml
<methodResponse>
  <params>
    <param>
      <value>
        <array>
          <data>
            <value>
              <struct>
                <member>
                  <name>email</name>
                  <value><string>test@example.com</string></value>
                </member>
              </struct>
            </value>
          </data>
        </array>
      </value>
    </param>
  </params>
</methodResponse>
```

## Querying XML with XPath (PHP)

In some cases, you may want to work with the raw XML response instead of relying on the XML-RPC library parsing.

PHP provides SimpleXML and XPath for querying XML data.

**Example**

```php
$xmlString = '...'; // raw XML response

$xml = simplexml_load_string($xmlString);

// Find all email values
$emails = $xml->xpath('//member[name="email"]/value/string');

foreach ($emails as $email) {
    echo (string)$email . PHP_EOL;
}
```

### How XPath Works

XPath lets you navigate XML using path-like expressions.

**Common patterns:**

 * ```/root/child```            Select direct nodes
 * ```//member```               Select nodes anywhere in document
 * ```//name="email"```         Match specific values

### Useful XPath Examples

**Get all members:**

```$xml->xpath('//member');```

**Get specific field:**

```$xml->xpath('//member[name="email"]/value/string');```

**Get multiple values:**

```$xml->xpath('//struct/member');```

**XPath is especially useful when:**

 * The XML structure is deeply nested
 * You only need specific fields
 * You want more control than the library provides

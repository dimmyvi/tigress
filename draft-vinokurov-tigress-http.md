---
title: "Transfer Digital Credentials Securely"
abbrev: "Tigress"
docname: draft-vinokurov-tigress-http-latest
submissiontype: IETF
category: std

ipr: trust200902
area: "Applications and Real-Time"
workgroup: "Transfer dIGital cREdentialS Securely"
keyword:
 - tigress
 - requirements
venue:
  group: "Transfer dIGital cREdentialS Securely"
  type: "Working Group"
  mail: "tigress@ietf.org"
  arch: "https://mailarchive.ietf.org/arch/browse/tigress/"
  github: "dimmyvi/tigress"
  latest: "https://datatracker.ietf.org/doc/draft-vinokurov-tigress-http/"

stand_alone: yes
smart_quotes: no
pi: [toc, sortrefs, symrefs]
v: 3

author:
 -
    ins: D. Vinokurov
    name: Dmitry Vinokurov
    organization: Apple Inc
    email: dvinokurov@apple.com
 -
    ins: Y. Karandikar
    name: Yogesh Karandikar
    organization: Apple Inc
    email: ykarandikar@apple.com
 -
    ins: M. Lerch
    name: Matthias Lerch
    organization: Apple Inc
    email: mlerch@apple.com
 -
    ins: A. Pelletier
    name: Alex Pelletier
    organization: Apple Inc
    email: a_pelletier@apple.com
 -
    ins: N. Sha
    name: Nick Sha
    organization: Alphabet Inc
    email: nicksha@google.com


normative:
  CCC-Digital-Key-30:
    author:
      org: Car Connectivity Consortium
    title: "Digital Key Release 3"
    date: 2022-07
    target: https://carconnectivity.org/download-digital-key-3-specification/


  ISO-18013-5:
    author:
      org: Cards and security devices for personal identification
    title: "Personal identification — ISO-compliant driving licence — Part 5: Mobile driving licence (mDL) application"
    date: 2021-09
    target: https://www.iso.org/standard/69084.html

informative:
  Tigress-req-00:
    author:
     -
      ins: D. Vinokurov
      name: Dmitry Vinokurov
     -
      ins: A. Pelletier
      name: Alex Pelletier
     -
      ins: C. Astiz
      name: Casey Astiz
     -
      ins: Y. Karandikar
      name: Yogesh Karandikar
     -
      ins: B Lassey
      name: Brad Lassey


    title: "Tigress requirements"
    date: 2023-04
    target: https://datatracker.ietf.org/doc/draft-ietf-tigress-requirements/

--- abstract

Digital Credentials allow users to access Homes, Cars or Hotels using their mobile devices. Once a user has a Credential on a device, sharing it to others is a natural use case. This document describes a sharing flow that allows convenient and seamless user experience, similar to sharing other digital assets like photos or documents. The sharing process should be secure and private. This document also defines a new transport to meet unique requirements of sharing a Credential.

--- middle

# Introduction

Mobile devices with ever increasing computational power and security capabilities are enabling various use cases. One such category includes use of mobile devices to gain access to a property that a user owns or rents or is granted access to. The cryptographic material and other data required to enable this use case is termed as Digital Credential. The process of getting a Digital Credential on a mobile device is termed as Provisioning.

Based on type of property, various public or proprietary standards govern details of Digital Credentials used to access them. These sets of standards are termed as Verticals. The details include policies, mechanism and practices to create, maintain and use Digital Credentials and vary considerably across Verticals.

Once a user has a Digital Credential for some Vertical provisioned on their mobile device, next natural use case is to share it with others. Sharing a Credential should feel like a natural extension of regular communication methods (like instant messaging, sms, email). The user experience of sharing a Credential should be intuitive, similar to sharing other digital assets like photos or documents. The sharing process should be secure and privacy preserving.

Credentials pose two requirements that differ from sharing other digital assets. The Initiator and Recipient devices may need to communicate back and forth to get the necessary Provisioning Information. The Provisioning information exchange must be limited to Initiator device and the first Recipient device to claim the information.

To achieve these goals, a new transport is necessary. This document specifies an Application Programming Interface(API) for a transport protocol built using standard HTTP [RFC9110] to create such a transport termed as Relay Server. The document also defines data in JSON standard [RFC8259] to enable a uniform user experience for securely sharing Digital Credentials of various types.


# Conventions & Definitions

{::boilerplate bcp14-tagged}

## General Terms
- Digital Credential (or simply Credential) - Cryptographic material and other data used to authorize User with an access point. The cryptographic material can also be used for mutual authentication between user device and access point.
- Digital Credential Vertical (or simply Vertical) - The public or proprietary standards that that define details of Digital Credentials for type of property accessed. The details include policy, process and mechanism to create, maintain and use Digital Credentials in the given Vertical.
- Provisioning - A process of adding a new Digital Credential to the device.
- Provisioning Entity - An entity that facilitates creation, update and termination (Lifecycle Management) of the Credential. Based on Vertical, the role of Provisioning Entity may be played by various actors in various stages of Credential lifecycle.
- Provisioning Information - data transferred from Initiator to Recipient that is both necessary and sufficient for the Recipient to Provision a Credential.
- Initiator - User and their device initiating a transfer of Provisioning Information to a Recipient.
- Recipient - User and their device that receives Provisioning Information and uses it to provision a new Credential.
- Relay Server - an intermediary server that provides a standardized and platform-independent way of transferring Provisioning Information between Initiator and Recipient, acting as a temporary store and forward service.
- Secret - a symmetric encryption key shared between an Initiator and Recipient device. It is used to encrypt Provisioning Information stored on the Relay server.


# Overview of Sharing Process

## Some Example Use Cases

- Amit owns a car that supports Digital Credentials. Being a tech enthusiast, he has the Credential provisioned on his mobile device. Amit can now use his mobile device to lock/unlock and operate his car. One Monday he is out of town and realizes that his car needs to be moved for street cleaning. He asks his neighbor Bob for help via their favorite instant messaging method. As Bob agrees, Amit shares the Digital Credential to Bob via the next instant message. Bob accepts the Credential and uses his mobile device to unlock Amit's car and drive it to the other side of street.

- Alice booked a room at a hotel that supports Digital Credentials. Being a frequent traveller, she has the Digital Credential provisioned on her mobile device. As her flight gets delayed, she realizes that her partner Bakari will reach the hotel first. So she shares the Digital Credential with him over email. Bakari sees the email after his flight lands and he accepts the shared Credential. On his arrival to the hotel, Bakari is able to access common areas and their room using his mobile device.


## Credential Sharing Flow

A simplified sharing flow is shown in the sequence diagram below. Initiator (User) uses their device to share a Credential over their preferred communication method. Recipient User accepts the Credential share invitation. Then the two devices go back and forth as necessary to transfer Provisioning Information. After the Provisioning Information transfer is complete Recipient device gets the Credential Provisioned.



~~~ plantuml-utxt
actor "Initiator User" as initPerson
participant "Initiator Device" as ID
participant "Relay Server" as RS
participant "Recipient Device" as RD
actor "Recipient User" as recPerson

initPerson -> ID: Initiate Credential Share
ID -> RS: upload Provisioning Information
ID -> RD: Invitation to accept Credential\n over IM, sms, email etc
recPerson -> RD : accept the Credential
RD -> RS: request Provisioning Information
RS -> RD: deliver Provisioning Information
loop Additional Data if Required
  RD -> RS: additional data request
  RS -> ID: Forward request
  ID -> RS: additional data response
  RS -> RD: forward response
end
~~~


## Things to note
- Initiator User and Recipient user may not be online at the same time.
- Users can pick any communication method for delivering invitation. Most communication methods have a goal to provide secure and private communication, but those properties can not be taken for granted.
- Once a Recipient User accepts the Invitation from a device, only that Recipient device SHALL get the Provisioning Information.
- Verticals may define a second factor to authenticate a Digital Credential Provisioned via sharing. The mechanisms and policies around the second factor are Vertical dependent and out of scope of this design.


# Design Details


- Initiator device composes Provisioning Information and encrypts it with a Secret before storing it in a mailbox on Relay Server
- Initiator Device calls CreateMailbox API endpoint on a Relay server in order to create a mailbox. A unique Mailbox Identifier is generated by the Relay server using a good source of entropy (preferably hardware-based entropy).
- Initiator device generates a unique token - an Initiator Device Claim - and stores it to the mailbox. Device Claim allows the Initiator Device presenting it to read and write data to / from the mailbox, thus binding it to the mailbox.
- A mailbox has limited lifetime configured with mandatory "expiration" parameter in mailboxConfiguration. When expired, the mailbox SHALL be deleted - refer to DeleteMailbox endpoint.  Relay server SHALL be responsible to periodically check for mailboxes that are past the expiration time and delete them.
- Relay server builds a unique URL link to a mailbox (for example, “https://relayserver.example.com/v1/m/1234567890”) and returns it to the Initiator Device. This link is sent as invitation to Recipient Device over communication method preferred by users.
- Recipient Device, having obtained both the URL link and the Secret, is ready to read the mailbox upon user action. It generates a unique token - a Recipient Device Claim - and presents it to the Relay server to read the mailbox. The Recipient Device Claim binds the Recipient device to the mailbox.
- Relay server only allows bound devices to read or write data to the mailbox or to delete the mailbox. Note that a Relay Server may host multiple mailboxes at the same time, each bound to various pairs of Initiator and Recipient Devices. Relay Server SHALL not be able to relate the devices across various mailboxes.
- Initiator Device or Recipient Device may delete the mailbox using the DeleteMailbox API call.
- Initiator and Recipient Devices can also deposit an optional notification token for the mailbox with the Relay Server. Relay Server can notify Initiator and Recipient devices when other side has deposited data in mailbox that is ready to be read. This improves user experience over polling mechanism that the devices would have to use otherwise.


~~~ plantuml-utxt
actor "Initiator User" as initUser
participant "Initiator Device" as Initiator
participant "Relay Server" as Relay
participant "Recipient Device" as Recipient
actor "Recipient User" as recUser

initUser -> Initiator : Share this Credential with Recipient User\n over communication method m_1

note over Initiator
  Create and encrypt Provisioning
  Info message_1 encrypted with Secret
end note
Initiator -> Relay: CreateMailbox \n(With DeviceClaim and Notification token)

Relay -> Initiator: URL link to mailbox

Initiator -> Recipient: URL link and Secret \n over preferred communication method m_1

recUser -> Recipient : Accept the Credential

Recipient -> Relay: ReadSecureContentFromMailbox \n (With DeviceClaim)
Relay -> Recipient: encrypted info

note over Recipient
  Decrypt with Secret to get Provisioning Info message_1
end note


note over Recipient
  Generate Provision Info message_2
  encrypted with Secret
end note
Recipient -> Relay: UpdateMailbox(encrypted info)
Relay -> Recipient: OK

Relay -> Initiator: Push Notification

Initiator -> Relay: ReadSecureContentFromMailbox
Relay -> Initiator: encrypted info
note over Initiator
  Decrypt with Secret to get Provision Info message_2
end note

note over Initiator
  Update with Provision Info message_3
  encrypted with Secret
end note

Initiator -> Relay: UpdateMailbox(encrypted info)
Relay -> Initiator: OK

Relay -> Recipient: Push Notification
Recipient -> Relay: ReadSecureContentFromMailbox
Relay -> Recipient: encrypted info

note over Relay, Recipient
  Decrypt with Secret for Provision Info message_3
end note

Recipient -> Relay: DeleteMailbox
Relay -> Recipient: OK

note over Recipient
  Finish Credential Provisioning
end note
~~~


## API parameters:

- Device Claim - a unique token allowing the caller to read from / write data to the mailbox. Exactly one Initiator Device and one Recipient Device SHOULD be able to read from / write secure payload to the mailbox. Initiator Device provides a Device Claim in order to create a mailbox. When the Relay server, having received a request from the Initiator Device, creates a mailbox, it binds this Initiator's Device Claim to the mailbox. When the Recipient Device first reads data from the mailbox it presents its Device Claim to the Relay Server, which binds the mailbox to the given Recipient Device. Thus, both Initiator and Recipient devices are bound to the mailbox (allowed to read from / write to it). Only Initiator and Recipient devices that present valid Device Claims are allowed to send subsequent read/update/delete calls to the mailbox. The value SHALL be a unique UUID {{!RFC4122}}. Initiator and Recipient MUST use different values for Device Claim. Implementation SHOULD assign unique values for new mailboxes (avoid re-using values).

- Notification Token - a short or long-lived unique token stored by the Initiator or Recipient Device in a mailbox on the Relay server, which allows Relay server to send a push notification to the Initiator or Recipient Device, informing them of updates in the mailbox.

- MailboxIdentifier - a unique identifier for the given mailbox, generated by the Relay server at the time of mailbox creation. The value is a UUID {{!RFC4122}}.


## Provisioning Information Structure

The Provisioning Information is the data transferred via the Relay Server between the Initiator Device and Recipient Device. Each use case defines its own specialized Provisioning Information format, but all formats must at least adhere to the following structure. Formats are free to define new top level keys, so clients shouldn't be surprised if a message of an unexpected format has specialized top level keys.

| Key           | Type       | Required | Description
| ------        | ---        | ---      | ---
| format        | String     |   Yes    | The Provisioning Information format that the message follows. This is used by the Initiator Device and Recipient Device to know how to parse the message.
| content       | Dictionary |   Yes    | A dictionary of content to be used for the credential transfer. See each format's specification for exact fields.

##### Provisioning Information Format

Each Provisioning Information format must have the message structure defined in an external specification.

| Format Type                              | Spec Link               | Description
| ---------------------------------------- | ----------------------- | ---
| digitalwallet.carkey.ccc                 | {{CCC-Digital-Key-30}}  | A digital wallet Provisioning Information for sharing a car key that follows the Car Connectivity Consortium specification.
| digitalwallet.generic.authorizationToken | {{ISO-18013-5}}         | A digital wallet Provisioning Information for sharing a generic pass that relies solely on an authorization token.

~~~
{
   "format" : "digitalwallet.carkey.ccc",
   "content": {
      // Format specific fields
   }
}
~~~
{: #provisioning-info-format title="Provisioning Information format"}


### Provisioning Information Encryption

Provisioning Information will be stored on the Relay Server encrypted. The Secret used to encrypt the Provisioning Information should be given to the Recipient Device via a "Share URL" (a URL link to a mailbox). The encrypted payload should be a data structure having the following key-value pairs:

- "type" (String, Required) - the encryption algorithm and mode used.
- "data" (String, Required) - Base64 encoded binary value of the encrypted Provisioning Information, aka the ciphertext.

Please refer to {{!RFC5116}} for the details of the encryption algorithm.

The following algorithms and modes are mandatory to implement:

- "AEAD_AES_128_GCM": AES symmetric encryption algorithm with key length 128 bits, in GCM mode with no padding.  Initialization Vector (IV) has the length of 96 bits randomly generated and tag length of 128 bits.

- "AEAD_AES_256_GCM": AES symmetric encryption algorithm with key length 256 bits, in GCM mode with no padding.  Initialization Vector (IV) has the length of 96 bits randomly generated and tag length of 128 bits.

~~~
{
    "type" : "AEAD_AES_128_GCM",
    "data" : "IV  ciphertext  tag"
}
~~~
{: #secure-payload-format title="Secure Payload Format example"}

## Share URL

A "Share URL" is the url a Initiator Device sends to the Recipient Device allowing it to retrieve the Provisioning Information stored on the Relay Server. A Share URL is made up of the following fields:

~~~
https://{RelayServerHost}/v{ApiVersion}/m/{MailboxIdentifier}?v={CredentialVertical}#{Secret}
~~~
{: #share-url-example title="Share URL example"}


| Field              | Location           | Required |
| -----------------  | ------------------ | -------- |
| RelayServerHost    | URL Host           | Yes      |
| ApiVersion         | URI Path Parameter | Yes      |
| MailboxIdentifier  | URI Path Parameter | Yes      |
| CredentialVertical | Query Parameter    | No       |
| Secret             | Fragment           | No       |

### Credential Vertical in Share URL

When a user interacts with a share URL on a Recipient Device it can be helpful to know what Credential Vertical this share is for. This is particularly important if the Recipient Device has multiple applications that can handle a share URL. For example, a Recipient Device might want to handle a general access share in their wallet app, but handle car key shares in a specific car application.

To properly route a share URL, the Initiator can include the Credential Vertical in the share URL as a query parameter. The Credential Vertical can't be included in the encrypted payload because the Recipient Device might need to open the right application before retrieving the secure payload. The Credential Vertical query parameter uses the "v" key and supports the below types. If no Credential Vertical is provided it will be assumed that this is a general access share URL.

| Vertical       | Value       |
| --------       | ----------- |
| General Access | a or *None* |
| Home Key       | h           |
| Car Key        | c           |

~~~
https://relayserver.example.com/v1/m/2bba630e-519b-11ec-bf63-0242ac130002?v=c#hXlr6aRC7KgJpOLTNZaLsw==
~~~
{: #car-key-share-url-example title="Car Key Share URL example"}

The Credential Vertical query parameter can be added to the share URL by the Initiator Device when constructing the full share URL that is going to be sent to the Recipient Device.


# API connection details

The Relay server API endpoint MUST be accessed over HTTP using an https URI {{?RFC2818}} and SHOULD use the default https port.
Request and response bodies SHALL be formatted as either JSON or HTML (based on the API endpoint). The communication protocol used for all interfaces SHALL be HTTPs.
All Strings SHOULD be UTF-8 encoded (Unicode Normalization Form C (NFC)).
An API version SHOULD be included in the URI for all interfaces. The version at the time of this document's latest update is v1. The version SHALL be incremented by 1 for major API changes or backward incompatible iterations on existing APIs.


# HTTP Headers

## Mailbox-Request-ID

All requests to and from Relay server will have an HTTP header "Mailbox-Request-ID". The corresponding response to the API will have the same HTTP header, which SHALL echo the value in the request header. This is used to identify the request associated to the response for a particular API request and response pair. The value SHOULD be a UUID {{!RFC4122}}.
The request originator SHALL match the value of this header in the response with the one sent in the request. If response is not received, caller may retry sending the request with the same value of "Mailbox-Request-ID".
Relay server SHOULD store the value of the last successfully processed "Mailbox-Request-ID" for each device based on the caller's Device Claim.
A key-value pair of "Device Claim" to "Mailbox-Request-ID" is suggested to store the last successfully processed request for each device.
In case of receiving a request with duplicated "Mailbox-Request-ID", Relay SHOULD respond to the caller with status code 201, ignoring the duplicate request body content.


## Mailbox-Device-Claim

All requests to CreateMailbox, ReadSecureContentFromMailbox and UpdateMailbox endpoints MUST contain this header. The value represents "Device Claim" (refer to Terminology)


## Mailbox-Device-Attestation
Request to CreateMailbox MAY contain this header. The value represents a Device Attestation (String, Optional) - optional remote OEM device proprietary attestation data


# HTTP access methods

## CreateMailbox

An application running on a remote device can invoke this API on Relay Server to create a mailbox and store secure data content to it (encrypted data specific to a provisioning partner). MailboxIdentifier is created by the Relay server as an UUID {{!RFC4122}}, using cryptographic entropy. A URL to the created mailbox to be returned to the caller in the response.

### Endpoint

POST  /{version}/m

### Request Parameters:

Path parameters

- version (String, Required) - the version of the API. At the time of writing this document, “v1”.

Header parameters

- Mailbox-Device-Attestation (String, Optional) - optional remote OEM device proprietary attestation data.
- Mailbox-Device-Claim (String, UUID, Required) - Device Claim (refer to Terminology).
- Mailbox-Request-ID (String, UUID, Required) - Unique request identifier.

### Consumes

This API call consumes the following media types via the Content-Type request header: `application/json`

### Produces

This API call produces the following media types via the Content-Type response header: `application/json`

### Request body

Request body is a complex structure, including the following fields:

- payload (Object, Required) - for the purposes of Tigress API, this is a data structure, describing Provisioning Information specific to Credential Provider. It consists of the following 2 key-value pairs:
    1. "type": "AEAD\_AES\_128_GCM" (refer to Encryption Format section).
    2. "data": BASE64-encoded binary value of ciphertext.
- displayInformation (Object, Required) - for the purposes of the Tigress API, this is a data structure. It allows an application running on a receiving device to build a visual representation of the credential to show to user.
The data structure contains the following fields:
    1. title (String, Required) - the title of the credential (e.g. "Car Key")
    2. description (String, Required) - a brief description of the credential (e.g. "a key to my personal car")
    3. imageURL (String, Required) - a link to a picture representing the credential visually.
- notificationToken (Object, Optional) - optional notification token used to notify an appropriate remote device that the mailbox data has been updated. Data structure includes the following (if notificationToken is provided it should include both fields):
    1. type (String, Required) - notification token name. Used to define which Push Notification System to be used to notify appropriate remote device of a mailbox data update. (E.g. "com.apple.apns" for APNS)
    2. tokenData (String, Required) - notification token data (data encoded based on specific device OEM notification service rules - e.g. HEX-encoded or Base64-encoded) - application-specific - refer to appropriate Push Notification System specification.
- mailboxConfiguration (Object, Optional) - optional mailbox configuration, defines access rights to the mailbox, mailbox expiration time. Required at the time of the mailbox creation. OEM device may provide this data in the request, Relay server shall define a default configuration, if it is not provided in the incoming request. Data structure includes the following:
    1. accessRights (String, Optional) - optional access rights to the mailbox for Initiator and  Recipient devices. Default access to the mailbox is Read and Delete.
Value is defined as a combination of the following values: "R" - for read access, "W" - for write access, "D" - for delete access. Example" "RD" - allows to read from the mailbox and delete it.
    2. expiration (String, Required) - Mailbox expiration time in "YYYY-MM-DDThh:mm:ssZ" format (UTC time zone) {{!RFC3339}}. Mailbox has limited livetime. Once expired, it SHALL be deleted - refer to DeleteMailbox endpoint. Relay server SHOULD periodically check for expired mailboxes and delete them.

~~~
{
   "notificationToken": {
        "type":"com.apple.apns",
        "tokenData":"APNS1234...QW"
    }
}
~~~
{: #apple-push-token title="Apple Push Token Example"}

~~~
{
    "displayInformation" : {
        "title" : "Hotel Pass",
        "description" : "Some Hotel Pass",
        "imageURL" : "https://example.com/sharingImage"
    },
    "payload" : {
        "type": "AEAD_AES_128_GCM",
        "data": "FDEC...987654321"
    },
    "notificationToken" : {
        "type" : "com.apple.apns",
        "tokenData" : “APNS...1234"
    },
    "mailboxConfiguration" : {
        "accessRights" : "RWD",
        "expiration" : "2022-02-08T14:57:22Z"
    }
}
~~~
{: #create-mailbox-request title="Create Mailbox Request Example"}

### Responses

`200`
Status: “200” (OK)

ResponseBody:

- urlLink (String, Required) - a full URL link to the mailbox including fully qualified domain name and mailbox Identifier. Refer to "Share URL" section for details.
- isPushNotificationSupported (boolean, Required) - indicates whether push notification is supported or not. The device uses this field to decide whether it should listen on the push topic or do long-polling.

~~~
{
    "urlLink":"https://relayserver.example.com/m/12345678-9...A-BCD",
    "isPushNotificationSupported":true
}
~~~
{: #create-mailbox-response title="Create Mailbox Response Example"}

`201`
Status: “201” (Created) - response to a duplicated request (duplicated "Mailbox-Request-ID"). Relay server SHALL respond to duplicated requests with 201 without creating a new mailbox. "Mailbox-Request-ID" passed in the first CreateMailbox request's header SHOULD be stored by the Relay server and compared to the same value in the subsequent requests to identify duplicated requests. If duplicate is found, Relay SHALL not create a new mailbox, but respond with 201 instead. The value of "Mailbox-Request-ID" of the last successfully completed request SHOULD be stored based on the Device Claim passed by the caller.

`400`
Bad Request - invalid request has been passed (can not parse or required fields missing).

`401`
Unauthorized - calling device is not authorized to create a mailbox. E.g. a device presented an invalid device claim or device attestation.


## UpdateMailbox

An application running on a remote device can invoke this API on Relay Server to update secure data content in an existing mailbox (encrypted data specific to a Provisioning Partner). The update effectively overwrites the secure payload previously stored in the mailbox.

### Endpoint

PUT  /{version}/m/{mailboxIdentifier}

### Request Parameters

Path parameters:

- version (String, Required) - the version of the API. At the time of writing this document, “v1”.
- mailboxIdentifier(String, Required) - MailboxIdentifier (refer to Terminology).

Header parameters:

- Mailbox-Device-Attestation (String, Optional) - optional remote OEM device proprietary attestation data.
- Mailbox-Device-Claim (String, UUID, Required) - Device Claim (refer to Terminology).
- Mailbox-Request-ID (String, UUID, Required) - Unique request identifier.

### Consumes

This API call consumes the following media types via the Content-Type request header: `application/json`

### Produces

This API call produces following media types via the Content-Type request header: `application/json`

### Request body

Request body is a complex structure, including the following fields:

- payload (Object, Required) - for the purposes of Tigress API, this is a data structure, describing Provisioning Information specific to Credential Provider. It consists of the following 2 key-value pairs:
    1. "type": "AEAD\_AES\_128_GCM" (refer to Encryption Format section).
    2. "data": BASE64-encoded binary value of ciphertext.

- notificationToken (Object, Optional) - optional notification token used to notify an appropriate remote device that the mailbox data has been updated. Data structure includes the following (if notificationToken is provided it should include both fields):
    1. type (String, Required) - notification token name. Used to define which Push Notification System to be used to notify appropriate remote device of a mailbox data update. (E.g. "com.apple.apns" for APNS)
    2. tokenData (String, Required) - notification token data (data encoded based on specific device OEM notification service rules - e.g. HEX-encoded or Base64-encoded) - application-specific - refer to appropriate Push Notification System specification.

~~~
{
     "payload" : {
        "type": "AEAD_AES_128_GCM",
        "data": "FDEC...987654321"
    },
    "notificationToken":{
        "type" : "com.apple.apns",
        "tokenData" : “APNS...1234"
    }
}
~~~
{: #update-mailbox-request title="Update Mailbox Request Example"}

### Responses

ResponseBody:

- isPushNotificationSupported (boolean, Required) - indicates whether push notification is supported or not. The device uses this field to decide whether it should listen on the push topic or do long-polling.

~~~
{
    "isPushNotificationSupported":true
}
~~~
{: #update-mailbox-response title="Update Mailbox Response Example"}

`200`
Status: “200” (OK)

`201`
Status: “201” (Created) - response to a duplicate request (duplicate "Mailbox-Request-ID"). Relay server SHALL respond to duplicate requests with 201 without performing mailbox update. "Mailbox-Request-ID" passed in the first UpdateMailbox request's header SHALL be stored by the Relay server and compared to the same value in the subsequent requests to identify duplicate requests. If duplicate is found, Relay SHALL not perform mailbox update, but respond with 201 instead.
The value of "Mailbox-Request-ID" of the last successfully completed request SHALL be stored based on the Device Claim passed by the caller.

`400`
Bad Request - invalid request has been passed (can not parse or required fields missing).

`401`
Unauthorized - calling device is not authorized to update the mailbox. E.g. a device presented the incorrect Device Claim.

`404`
Not Found - mailbox with provided mailboxIdentifier not found.


## DeleteMailbox

An application running on a remote device can invoke this API on Relay Server to close the existing mailbox after it served its purpose. Recipient or Initiator Device needs to present a Device Claim in order to close the mailbox.

### Endpoint

DELETE /{version}/m/{mailboxIdentifier}

### Request Parameters

Path parameters:

- version (String, Required) - the version of the API. At the time of writing this document, “v1”.
- mailboxIdentifier(String, Required) - MailboxIdentifier (refer to Terminology).

Header parameters:

- Mailbox-Device-Claim (String, UUID, Required) - Device Claim (refer to Terminology).
- Mailbox-Request-ID (String, UUID, Required) - Unique request identifier.

### Responses

`200`
Status: “200” (OK)

`401`
Unauthorized - calling device is not authorized to delete a mailbox. E.g. a device presented the incorrect Device Claim.

`404`
Not Found - mailbox with provided mailboxIdentifier not found. Relay server may respond with 404 if the Mailbox Identifier passed by the caller is invalid or mailbox has already been deleted (as a result of duplicate DeleteMailbox request).


## ReadDisplayInformationFromMailbox

An application running on a remote device can invoke this API on Relay Server to retrieve public display information content from a mailbox. Display Information shall be returned in OpenGraph format (please refer to https://ogp.me for details).
OpenGraph-formatted display information is required to display a preview of credential in a messaging application, e.g. iMessage or WhatsApp.

### Endpoint

GET /{version}/m/{mailboxIdentifier}

### Request Parameters

Path parameters:

- version (String, Required)- the version of the API. At the time of writing this document, “v1”.
- mailboxIdentifier(String, Required) - MailboxIdentifier (refer to Terminology).

### Produces

This API call produces the following media types via the Content-Type response header: `text/html`

### Responses

`200`
Status: “200” (OK)

ResponseBody :

- displayInformation (Object, Required) - visual representation of digital credential in OpenGraph format (please refer to https://ogp.me for details).

~~~
    "<html prefix="og: https://ogp.me/ns#">
     <head>
     <title>Hotel Pass</title>
     <meta property="og:title" content="Hotel Pass" />
     <meta property="og:type" content="image/jpeg" />
     <meta property="og:description" content="Some Hotel Pass" />
     <meta property="og:url" content="share://" />
     <meta property="og:image" content="https://example.com/photos/photo.jpg" />
     <meta property="og:image:width" content="612" />
     <meta property="og:image:height" content="408" /></head>
     </html>"
~~~
{: #read-display-information-response title="Read Display Information Response Example"}

`404`
Not Found - mailbox with provided mailboxIdentifier not found.


## ReadSecureContentFromMailbox

An application running on a remote device can invoke this API on Relay Server to retrieve secure payload content from a mailbox (encrypted data specific to a Provisioning Information Provider).

### Endpoint

POST /{version}/m/{mailboxIdentifier}

### Request Parameters

Path parameters:

- version (String, Required) - the version of the API. At the time of writing this document, “v1”.
- mailboxIdentifier(String, Required) - MailboxIdentifier (refer to Terminology).

Header parameters:

- MAilbox-Device-Claim (String, UUID, Required) - Device Claim (refer to Terminology).

### Produces

This API call produces the following media types via the Content-Type response header: `application/json`

### Responses

`200`
Status: “200” (OK)

ResponseBody :

- payload (String, Required) - for the purposes of Tigress API, this is a JSON metadata blob, describing Provisioning Information specific to Credential Provider.
- displayInformation (Object, Required) - for the purposes of the Tigress API, this is a JSON data blob. It allows an application running on a receiving device to build a visual representation of the credential to show to user. Specific to Credential Provider.
- expiration (String, Required) - the date that the mailbox will expire. The mailbox expiration time is set during mailbox creation. Expiration time should be a complete {{!RFC3339}} date string in "YYYY-MM-DDThh:mm:ssZ" format (UTC time zone), and can be used to allow receiving clients to show when a share will expire.

~~~
{
    “displayInformation" : {
        "title" : "Hotel Pass",
        "description" : "Some Hotel Pass",
        "imageURL" : "https://example.com/sharingImage"
    },
    "payload" : {
        "type": "AEAD_AES_128_GCM",
        "data": "FDEC...987654321"
    },
    "expiration": "2021-11-03T20:32:34Z"
}
~~~
{: #read-secure-content-response title="Read Secure Content Response Example"}

`401`
Unauthorized - calling device is not authorized to read the secure content of the mailbox. E.g. a device presented the incorrect Device Claim.

`404`
Not Found - mailbox with provided mailboxIdentifier not found.


## RelinquishMailbox

An application running on a remote device can invoke this API on Relay Server to relinquish their ownership of the mailbox. Recipient Device needs to present the currently established Recipient Device Claim in order to relinquish their ownership of the mailbox. Once relinquished, the mailbox can be bound to a different Recipient Device that presents its Device Claim in a ReadSecureContentFromMailbox call.

### Endpoint

PATCH /{version}/m/{mailboxIdentifier}

### Request Parameters

Path parameters:

- version (String, Required) - the version of the API. At the time of writing this document, “v1”.
- mailboxIdentifier(String, Required) - MailboxIdentifier (refer to Terminology).

Header parameters:

- Mailbox-Device-Claim (String, UUID, Required) - Device Claim (refer to Terminology).
- Mailbox-Request-ID (String, UUID, Required) - Unique request identifier.

### Responses

`200`
Status: “200” (OK)

`201`
Status: “201” (Created) - response to a duplicate request (duplicate "Mailbox-Request-ID"). Relay server SHALL respond to duplicate requests with 201 without performing mailbox relinquish. "Mailbox-Request-ID" passed in the first RelinquishMailbox request's header SHALL be stored by the Relay server and compared to the same value in the subsequent requests to identify duplicate requests. If duplicate is found, Relay SHALL not perform mailbox relinquish, but respond with 201 instead.
The value of "Mailbox-Request-ID" of the last successfully completed request SHALL be stored based on the Device Claim passed by the caller.

`401`
Unauthorized - calling device is not authorized to relinquish a mailbox. E.g. a device presented the incorrect Device Claim, or the device is not bound to the mailbox.

`404`
Not Found - mailbox with provided mailboxIdentifier not found. Relay server may respond with 404 if the Mailbox Identifier passed by the caller is invalid.

# Security Considerations

The following threats and mitigations have been considered:

- Initiator shares with the wrong Recipient
    - Initiator SHOULD be encouraged to share Secret over a channel allowing authentication of the Recipient (e.g. voice).
    - Verticals allow Initiator to cancel in-flight shares and delete completed shares.
- Malicious Recipient forwards the share to 3rd party without redeeming it or the Recipient's device is compromised.
    - No mitigation, the Initiator SHOULD only share with receivers they trust.
- Share-url and secret is exposed to Recipient plus some other users.
    - Verticals SHALL ensure that the Provisioning Information of a share can only be redeemed once.
    - Relay Server SHALL ensure that only first Receiver to claim Provisioning Information gets it.
- Network attacks
    - Machine-in-the-middle:
      Relay server SHALL only allow TLS connections.
      URLs displayed to user SHOULD include the https scheme.
    - MailboxIdentifier guessing:
      the MailboxIdentifier is a version 4 UUID {{!RFC4122}} which SHOULD contain 122-bits of cryptographic entropy, making brute-force attacks impractical.
- Risk of hosting malicious or untrusted scripts by relay server preview page (ReadDisplayInformationFromMailbox)
    - Relay server should either not allow hosting a third party JavaScripts on a preview page or implement a policy and utilize tools to maintain the trust of such scripts (e.g. force client to verify the script against a good known hash of it).

## Initiator/Recipient privacy

- At no time Relay server SHALL store or track the identities of both Initiator and Recipient devices.
- The value of the Notification Token shall not contain information allowing the identification of the device providing it. It SHOULD also be different for every new share to prevent the Relay server from correlating different sharing.
- Notification token SHOULD only inform the corresponding device that there has been a data update on the mailbox associated to it (by Device Claim). Each device SHOULD keep track of all mailboxes associated with it and make read calls to appropriate mailboxes.
- Both Initiator and Recipient devices SHOULD store the URL of the Relay server they use for an active act of credential transfer.
- The value of Mailbox-Device-Attestation header parameter SHALL not contain information allowing the identification of the device providing it. It SHOULD also be different for every new share to prevent the Relay server from correlating different sharing.
- Display Information is not encrypted, therefore, it SHOULD not contain any information allowing to identify Initiator or Recipient devices.

## Credential's confidentiality and integrity

- Content of the mailbox SHALL be only visible to devices having Secret.
- Relay server MUST not receive the Secret with the MailboxIdentifier at any time.
- Content of the mailbox MUST guaranty its integrity with cryptographic checksum (e.g. MAC, AES-GCM tag).
- Relay server SHALL periodically check and delete expired mailboxes ( refer to expiration parameter in the CreateMailbox request).
- It is recommended that URL and secret are send separately. But if the Initiator sends both URL and the Secret as a single URL, Secret MUST be appended as URI fragment {{!RFC3986}}.  Recipient Device, upon receipt of such URL, MUST remove the Fragment (Secret) before calling the Relay server API.

~~~
“https://relayserver.example.com/v1/m/{mailboxIdentifier}#{Secret}”
~~~
{: #link-with-fragment title="Example of URL with Secret as URI Fragment"}

## Second factor authentication for Recipient Credential Provisioning

- Vertical determines need of a second factor to Provision Credential on Recipient device. This determination is done on the basis of known security properties of the communication method used to send the invitation.
- Verticals can use PIN codes, presence of Initiator Credential or other mechanisms as second factor.
- Details of the second factor and policies around use of the second factor is out of scope of this document.


# IANA Considerations

This document registers new headers, "Mailbox-Request-ID", "Mailbox-Device-Claim" and "Mailbox-Device-Attestation"
in the "Permanent Message Header Field Names" <[](https://www.iana.org/assignments/message-headers)>.

~~~
    +----------------------------+----------+--------+---------------+
    | Header Field Name          | Protocol | Status |   Reference   |
    +----------------------------+----------+--------+---------------+
    | Mailbox-Request-ID         |   http   |  std   | This document |
    | Mailbox-Device-Claim       |   http   |  std   | This document |
    | Mailbox-Device-Attestation |   http   |  std   | This document |
    +----------------------------+----------+--------+---------------+
~~~
{: #iana-header-type-table title="Registered HTTP Header"}


--- back

# Contributors

The following people provided substantive contributions to this document:

- Ben Chester
- Casey Astiz
- Jean-Luc Giraud
- Matt Byington
- Alexey Bulgakov
- Tommy Pauly
- Crystal Qin
- Adam Bar-Niv
- Manuel Gerster
- Igor Gariev

# Acknowledgments

TODO acknowledge.

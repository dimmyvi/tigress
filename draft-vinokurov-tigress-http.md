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
    title: "Personal identification — ISO-compliant driving license — Part 5: Mobile driving license (mDL) application"
    date: 2021-09
    target: https://www.iso.org/standard/69084.html

--- abstract

Digital Credentials allow users to access Homes, Cars or Hotels using their mobile devices. Once a user has a Credential on a device, sharing it to others is a natural use case. Process of sharing credentials should be secure, privacy preserving and have a seamless user experience. To facilitate Credential sharing, a new transport is required. This document defines that new transport to meet unique requirements of sharing a Credential.

--- middle

# Introduction

Mobile devices with ever increasing computational power and security capabilities are enabling various use cases. One such category includes use of mobile devices to gain access to a property that a user owns or rents or is granted access to. The cryptographic material and other data required to enable this use case is termed as Digital Credential.

Based on type of property, various public or proprietary standards govern details of Digital Credentials. These sets of standards and the bodies setting them are collectively termed as Verticals. The details include policies, mechanism and practices to create, maintain and use Digital Credentials. The process of getting a Digital Credential on a mobile device is termed as Provisioning.

Once a user has a Digital Credential provisioned on their mobile device, sharing it to others is a natural use case. Sharing a Credential should feel like a natural extension of regular communication methods (like instant messaging, sms, email). The user experience of sharing a Credential should be intuitive, similar to sharing other digital assets like photos or documents. The sharing process should be secure and privacy preserving.

Credentials pose two unique requirements that differ from sharing other digital assets. The Initiator and Recipient devices may need to communicate back and forth to transfer the necessary Provisioning Information. The Provisioning Information exchange must be limited to Initiator device and the first Recipient device to claim the information.

To achieve these goals, a new transport is necessary. This document defines  HTTP [RFC9110] based API to create such a transport, termed as Relay Server. The document also defines data in JSON standard [RFC8259] to enable a uniform user experience for securely sharing Digital Credentials of various types.


# Conventions & Definitions

{::boilerplate bcp14-tagged}

## General Terms
- Digital Credential (or simply Credential) - Cryptographic material and other data used to authorize User with an access point. The cryptographic material can also be used for mutual authentication between user device and access point.
- Digital Credential Vertical (or simply Vertical) - The public or proprietary standards that that define details of Digital Credentials for type of property accessed. The details include policy, process and mechanism to create, maintain and use Digital Credentials in the given Vertical.
- Provisioning - A Vertical defined process of adding a new Digital Credential to the device.
- Provisioning Entity - An entity that facilitates creation, update and termination (Lifecycle Management) of the Credential. Based on Vertical, the role of Provisioning Entity may be played by various actors in various stages of Credential lifecycle.
- Provisioning Information - data transferred from Initiator to Recipient that is both necessary and sufficient for the Recipient to Provision a Credential.
- Initiator - User and their device initiating a transfer of Provisioning Information to a Recipient.
- Recipient - User and their device that receives Provisioning Information and uses it to provision a new Credential.
- Relay Server - an intermediary server that provides a standardized and platform-independent way of transferring Provisioning Information between Initiator and Recipient, acting as a temporary store and forward service. This is the new transport defined by this document.
- Secret - a symmetric encryption key shared between an Initiator and Recipient device. It is used to encrypt Provisioning Information stored on the Relay server.


# Sharing Process

## Some Example Use Cases

- Amit owns a car that supports Digital Credentials. Being a tech enthusiast, he has the Credential provisioned on his mobile device. Amit can now use his mobile device to lock/unlock and operate his car. One Monday he is out of town and realizes that his car needs to be moved for street cleaning. He asks his neighbor Bob for help via their favorite instant messaging method. As Bob agrees, Amit shares the Digital Credential to Bob via the next instant message. Bob accepts the Credential and uses his mobile device to unlock Amit's car and drive it to the other side of street.

- Alice booked a room at a hotel that supports Digital Credentials. Being a frequent traveller, she has the Digital Credential provisioned on her mobile device. As her flight gets delayed, she realizes that her partner Bakari will reach the hotel first. So she shares the Digital Credential with him over email. Bakari sees the email after his flight lands and he accepts the shared Credential. On his arrival to the hotel, Bakari is able to access common areas and their room using his mobile device.


## Credential Sharing Flow

A simplified sharing flow is shown in the sequence diagram below. Initiator (User) sends an invitation to share a Credential over their preferred communication method. Recipient (user) accepts the Credential share invitation. Then the two devices go back and forth as necessary to transfer Provisioning Information without further interaction by user. After the transfer is complete Recipient device gets the Credential Provisioned according to Vertical defined process.


~~~ plantuml-utxt
actor "Initiator User" as initPerson
participant "Initiator Device" as ID
participant "Relay Server" as RS
participant "Recipient Device" as RD
actor "Recipient User" as recPerson

initPerson -> ID: Initiate Credential Share
ID -> RS: create a mailbox, establish Initiator claim
ID -> RD: Invitation to accept Credential\n over IM, sms, email etc
recPerson -> RD : accept the Credential
RD -> RS: establish Recipient claim
loop Transfer
  RD -> RS: request Provisioning Information
  RS -> ID: Forward request
  ID -> RS: Provisioning Information response
  RS -> RD: forward response
end

note over RD
  Finish Credential Provisioning
end note

~~~

## Relay Server Design Requirements

Based on the sharing flow, we can see that Relay server is an important component of the credential Sharing flow. Relay server design needs to adhere to following requirements :

- Relay server SHALL provide confidentiality and integrity to the transfer of Provisioning Information.
- Transfer of Provisioning Information MAY require several round trips. Relay server SHALL guarantee round trip communication between initiator device and first device to establish Recipient claim.
- Relay Server SHALL support flow of information that MAY NOT always be in turn taking fashion. Same party SHALL be allowed to send back to back messages. E.g. a cancel message may be sent by same party that sent the previous message.
- User involvement in the process needs to be minimal for a seamless user experience. A lay user is expected to be unaware of Relay Server (similar to any transport protocols like TCP/IP). So Relay Server SHALL be able to function without user interaction.
- Initiator and Recipient MAY NOT be online at the same time. So Relay Server SHALL be able to store and forward data. It is RECOMMENDED to have notification mechanism for snappy user experience.
- To protect user privacy, Relay server SHALL NOT require any identifying information of the 2 parties involved in the transfer.
- Relay Server SHALL allow encrypted data (that can not be deciphered by the Relay Server itself) to be stored and transferred.
- Relay Server MAY host multiple mailboxes at the same time, each bound to various pairs of Initiator and Recipient Devices. Relay Server SHALL not be able to relate the devices across various mailboxes.
- User preferred communication methods need to be allowed for invitation delivery. It's assumed that user is familiar with them and trusts them to be secure enough to deliver messages to intended recipient. But security properties of the methods can not be taken for granted in the design of the Relay Server. Verticals can require second factor to authenticate Recipient if they deem it necessary. Policies and mechanisms for this second factor are in the realm of the Verticals and outside the scope of this document.





# Relay Server Design

## Design Elements

- Mailbox - A place to store data on the Relay Server. A reader can also read the data from mailbox.

- MailboxIdentifier - a unique identifier for the given mailbox, generated by the Relay server at the time of mailbox creation. The value is a UUID {{!RFC4122}}.

- Device Claim - a unique token allowing the caller to read from / write data to the mailbox. Initiator Device generates a Device Claim and presents it to the Relay Server at time of mailbox creation. Relay server creates a mailbox, and binds it to Initiator's Device Claim. Recipient Device generates a Device Claim and presents it to the Relay Server, at time of first read from mailbox. Relay server binds the mailbox to the Recipient's Device Claim. Thus, both Initiator and Recipient devices are bound to the mailbox (allowed to read from / write to it). Only Initiator and Recipient devices that present valid Device Claims are allowed to send subsequent read/update/delete calls to the mailbox. The value SHALL be a unique UUID {{!RFC4122}}. Initiator and Recipient MUST use different values for Device Claim. Implementation SHOULD assign unique values for new mailboxes (avoid re-using values).

- Notification Token - a short or long-lived unique token stored by the Initiator or Recipient Device in a mailbox on the Relay server. This allows Relay server to send a push notification to the Initiator or Recipient Device, informing them of updates in the mailbox.


## API connection details

The Relay server API endpoint MUST be accessed over HTTP using an https URI {{?RFC2818}} and SHOULD use the default https port. This ensures confidentiality property of the transfer process.

Request and response bodies SHALL be formatted as either JSON or HTML (based on the API endpoint). The communication protocol used for all interfaces SHALL be HTTPs.

All Strings SHOULD be UTF-8 encoded (Unicode Normalization Form C (NFC)).

An API version SHOULD be included in the URI for all interfaces. The version at the time of this document's latest update is v1. The version SHALL be incremented by 1 for major API changes or backward incompatible iterations on existing APIs.

## Sharing Flow With API calls

 Sequence diagram below shows an example sharing flow with detailed API calls.

- Initiator Device composes Provisioning Information and encrypts it with a Secret before storing it in a mailbox on Relay Server
- Initiator Device generates a unique token - an Initiator Device Claim - to be sent to Relay Server. Initiator Device Claim allows the Initiator Device to read and write data to / from the mailbox, thus binding it to the mailbox.
- Initiator Device can also create an optional notification token for the mailbox with the Relay Server. Relay Server can notify Initiator devices when other side has deposited data in mailbox that is ready to be read. This improves user experience over polling mechanism that the devices would have to use otherwise.
- Initiator Device calls CreateMailbox API endpoint on a Relay server and provides Device Claim and optional Notification token. Relay server creates the mailbox and assigns a unique Mailbox Identifier generated using a good source of entropy (preferably hardware-based entropy).
- A mailbox has limited lifetime configured with mandatory "expiration" parameter in mailboxConfiguration. When expired, the mailbox SHALL be deleted - refer to DeleteMailbox endpoint.  Relay server SHALL be responsible to periodically check for mailboxes that are past the expiration time and delete them.
- Relay server builds a unique URL link to a mailbox (for example, “https://relayserver.example.com/v1/m/1234567890”) and returns it to the Initiator Device.
- Initiator sends this link as invitation to Recipient Device over communication method preferred by users.
- Recipient Device, having obtained both the URL link and the Secret, is ready to read the mailbox upon user action.
- Recipient Device generates a unique token - a Recipient Device Claim - to be sent to Relay Server. Recipient Device Claim allows the Recipient Device to read and write data to / from the mailbox, thus binding it to the mailbox.
- Recipient Device can also create an optional notification token for the mailbox with the Relay Server for snappy user experience.
- Recipient Device calls ReadSecureContentFromMailbox API endpoint on the Relay Server and provides Device Claim and optional Notification token. If this is the first Recipient claim, Relay server allows the read and binds the device to the mailbox. Thus establishing a connection between Initiator and Recipient devices facilitated by Relay Server.
- Initiator Device or bound Recipient Device may delete the mailbox using the DeleteMailbox API call.


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
    2. expiration (String, Required) - Mailbox expiration time in "YYYY-MM-DDThh:mm:ssZ" format (UTC time zone) {{!RFC3339}}. Mailbox has limited lifetime. Once expired, it SHALL be deleted - refer to DeleteMailbox endpoint. Relay server SHOULD periodically check for expired mailboxes and delete them.

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

- Mailbox-Device-Claim (String, UUID, Required) - Device Claim (refer to Terminology).

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


# Provisioning Information Structure

The Provisioning Information is the data transferred via the Relay Server between the Initiator Device and Recipient Device. Each use case defines its own specialized Provisioning Information format, but all formats must at least adhere to the following structure. Formats are free to define new top level keys, so clients shouldn't be surprised if a message of an unexpected format has specialized top level keys.

| Key           | Type       | Required | Description
| ------        | ---        | ---      | ---
| format        | String     |   Yes    | The Provisioning Information format that the message follows. This is used by the Initiator Device and Recipient Device to know how to parse the message.
| content       | Dictionary |   Yes    | A dictionary of content to be used for the credential transfer. See each format's specification for exact fields.

## Provisioning Information Format

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


## Provisioning Information Encryption

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






# Security Considerations

## Relay Server defined in this document

### Confidentiality & Integrity
- Relay Server SHALL only allow TLS connections to thwart eavesdropping or disruption of communication between Relay Server and Initiator/Recipient.
- Relay Server SHALL use Device Claim to bind Initiator and exactly one Recipient device to a mailbox. The binding prevents eavesdropping or disruption of communication between Initiator and Recipient via mailbox.

### Network attacks
- An attacker may attempt to guess the MailboxIdentifier to eavesdrop or disrupt communication. Using version 4 UUID {{!RFC4122}} for MailboxIdentifier SHOULD contain 122-bits of cryptographic entropy. That makes brute-force guessing attacks impractical. Also Relay Server generating MailboxIdentifiers removes any chance of collision.
- It is possible to hosting malicious or untrusted scripts by relay server preview page (ReadDisplayInformationFromMailbox). That can be mitigated by not hosting a third party JavaScripts on a preview page. Another approach is with a policy and tools to maintain the trust of such scripts (e.g. force client to verify the script against a good known hash of it).
- Relay server SHALL periodically check and delete expired mailboxes ( refer to expiration parameter in the CreateMailbox request). This prevents un-authorized data leaks in future in addition to general cleanup.

### Privacy Considerations
- Relay Server SHALL not look into data exchanged over mailbox. This is achieved by encrypting that data and making sure the Secret doesn't land on Relay Server.
- At no time Relay server SHALL store or track the identities of Initiator and Recipient. This is achieved by letting clients pick Device Claims and Notification Tokens.
- Relay Server SHALL NOT be able to identify different mailboxes that same device is interacting with. This is achieved by letting clients pick Device Claims and Notification Tokens.

## Clients of Relay Server

### Confidentiality & Integrity
- Clients SHALL encrypt contents of the mailbox to protect it from getting revealed to the Relay Server.
- Clients SHALL check cryptographic checksum of the content to verify integrity of data. It's in the realm of Verticals to define the details and out of scope of this document.
- It is recommended that URL and secret are send separately. But if the Initiator sends both URL and the Secret as a single URL, Secret MUST be appended as URI fragment {{!RFC3986}}. Recipient Device, upon receipt of such URL, MUST remove the Fragment (Secret) before calling the Relay server API. This ensures that Relay Server never ends up with the Secret to decode data.

~~~
“https://relayserver.example.com/v1/m/{mailboxIdentifier}#{Secret}”
~~~
{: #link-with-fragment title="Example of URL with Secret as URI Fragment"}


### Privacy Considerations
- Notification Token SHALL NOT not contain identifying information. It SHOULD also be different for every new share to prevent the Relay server from correlating different shares.
- Notification token SHOULD only inform the corresponding device that there is an update available on the corresponding mailbox. Each device SHOULD keep track of all mailboxes associated with it and make read calls to appropriate mailboxes.
- The value of Mailbox-Device-Attestation header parameter SHALL not contain identifying information. It SHOULD also be different for every new share to prevent the Relay server from correlating different shares.
- Display Information is not encrypted, therefore, it SHOULD not contain any identifying information.


## Overall System

The overall system security considerations are in the realm of Verticals. They are mentioned here for getting a better picture. But these are not in scope of this document as Relay Server is a piece of the overall System.

### Initiator shares with the wrong Recipient
- Verticals allow Initiator to cancel in-flight shares and delete completed shares.

### Malicious Recipient forwards the share to 3rd party without redeeming it or the Recipient's device is compromised.
- No mitigation, the Initiator SHOULD only share with receivers they trust.

### Invitation Channel Security
- For better user experience, the sharing flow SHOULD allow user preferred channels. Users are familiar with these channels and use them frequently for communication. Users typically consider these channels as secure enough and trust them to deliver messages to intended recipient. Some of these channels are end to end encrypted and hence very secure and some are not. So depending on channel used it's possible that the invitation is leaked to determined attackers.
- Verticals can deploy various mitigations for this scenario.
    - Verticals SHALL ensure that the Provisioning Information of a share can only be redeemed exactly once. Relay Server helps in this by guaranteeing that only one Recipient device gets the Provisioning Information.
    - Verticals can use second factor to authenticate the Recipient. Verticals can use PIN codes, presence of Initiator Credential or other mechanisms as second factor. The second factor introduces friction to the smooth user experience during the Provisioning process or at time of use of Credential. Details of the second factor and policies around use of the second factor are out of scope of this document.


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

- Casey Astiz
- Adam Bar-Niv
- Alexey Bulgakov
- Matt Byington
- Ben Chester
- Igor Gariev
- Manuel Gerster
- Jean-Luc Giraud
- Tommy Pauly
- Crystal Qin



# Acknowledgments

TODO acknowledge.

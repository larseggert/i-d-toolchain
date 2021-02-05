---

title: Stress-Test for i-d-toolchain
docname: draft-i-d-toolchain-test
date: {DATE}
category: info
ipr: trust200902

stand_alone: yes
pi: [toc, sortrefs, symrefs, docmapping]

author:

-
  name: Lars Eggert
  org: NetApp
  street: Stenbergintie 12 B
  city: Kauniainen
  code: "02700"
  country: FI
  email: lars@eggert.org
  uri: "https://eggert.org/"

--- abstract

This document tries to exercise all the different tools that kramdown-rfc2629
can use.

--- middle

# Introduction

# Conventions

{::boilerplate bcp14}

# math

~~~ math
K = \sqrt[3]{\frac{W_{max} - cwnd_{start}}{C}}
~~~

# goat

~~~ goat
  .-.
 |o o|
C| | |D
 | - |
 '___'
~~~

# ditaa

~~~ ditaa
----+  /----\  +----+
    :  |    |  :    |
    |  |    |  |{s} |
    v  \-=--+  +----+
~~~

# mscgen

~~~ mscgen
msc {
 a [label="Client"],b [label="Server"];
 a=>b [label="data1"];
 a-xb [label="data2"];
 a=>b [label="data3"];
 a<=b [label="ack1, nack2"];
 a=>b [label="data2", arcskip="1"];
 |||;
 a<=b [label="ack3"];
 |||;
}
~~~

# plantuml

~~~ plantuml
@startuml
Alice -> Bob: test
@enduml
~~~

# mermaid

~~~ mermaid
graph TD
A[Christmas] -->|Get money| B(Go shopping)
B --> C{Let me think}
C -->|One| D[Laptop]
C -->|Two| E[iPhone]
C -->|Three| F[Car]
~~~

# Security Considerations

This document raises no security considerations.

# IANA Considerations

This document does not require any IANA actions.

--- back

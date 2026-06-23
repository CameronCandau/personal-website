---
tags:
  - OSINT
  - Tor
---
![[Pasted image 20250614092727.png]]

```
cat note.txt
YOU HAVE BEEN PENETRATED.

We are group of cyber warriors from JUCHE JAGUAR. You are infected.
Your network, systems, documents, inner secrets — all under full control.

You pretend to be innocent company, but we know your lies and dirty money games.
We see your crimes. We expose your shadow. We now give you one final mercy option.

WE HOLD:

Secret plans, financial crime records

Executive communications and data treasure

System control ability at root level

Your time is limited. Clock is counting.
To restore order and avoid global shame, you must pay [X] Bitcoin in 120 hours.

SEND PAYMENT TO:
http://jjpwn5u6ozdmxjurfitt42hns3qovikeyhocx5b2byoxgupnuzd2vkid.onion/

After payment is confirmed, we will:

Send unlock keys

Remove all stolen data from secure vault

Cease further punishment

If you ignore:

All data go public

Systems will be destroyed

Name will be burned in global news fire

NO GAME. NO NEGOTIATION. NO MERCY.
We are not common criminal. We are mission.
We do not bluff. We do not stop.
Truth is weapon. Fear is justice.
```

We need to use the [Tor Browser](https://www.torproject.org/download/) to access this .onion address:
`http://jjpwn5u6ozdmxjurfitt42hns3qovikeyhocx5b2byoxgupnuzd2vkid.onion/`

![[Pasted image 20250614093050.png]]

Viewing the page's source, I found that the flag was hardcoded in a hidden form field.

![[Pasted image 20250614093040.png]]


`C1{h1dd3n_f131ds_0f_0n10ns}`
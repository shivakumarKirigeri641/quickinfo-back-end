-- 201_quickinfo_seed_content.sql — QuickInfo's services, Privacy Policy and
-- Terms & Conditions.
--
-- Each block only inserts into an empty table, so content edited later in the
-- database is never overwritten. To change wording, UPDATE the row: the page's
-- "last updated" date follows updated_at.
--
-- Placeholders the owner must review before launch are written in [BRACKETS].

BEGIN;

/* ══════════════════════════════════════════════════════════════ services */

INSERT INTO quickinfo_services (slug, name, channel, summary, features, display_order)
SELECT * FROM (VALUES
  ('whatsapp-info-bots', 'WhatsApp Info Bots', 'whatsapp',
   'Answer customer questions instantly on WhatsApp with menus, look-ups and automated replies, round the clock.',
   '["Menu and keyword driven replies", "Live data look-ups", "Hand-over to a human when needed"]'::jsonb, 1),
  ('alerts-reminders', 'Alerts & Reminders', 'whatsapp_web',
   'Send timely due-date reminders, status updates and expiry alerts so your customers never miss what matters.',
   '["Scheduled and event-driven alerts", "Approved WhatsApp templates", "Delivery and read tracking"]'::jsonb, 2),
  ('bookings-digital-tickets', 'Bookings & Digital Tickets', 'whatsapp_web',
   'Take bookings and issue verifiable digital tickets or passes that customers receive on WhatsApp or the web.',
   '["Slot and capacity management", "QR-coded tickets", "Entry scanning for staff"]'::jsonb, 3),
  ('payments-collections', 'Payments & Collections', 'whatsapp_web',
   'Collect payments through secure payment links shared on WhatsApp or your website, with automatic confirmations.',
   '["UPI, card and net-banking via payment gateway", "Instant receipts", "Payment status alerts"]'::jsonb, 4),
  ('quizzes-engagement', 'Quizzes & Engagement', 'whatsapp',
   'Keep your audience engaged with daily quizzes, polls and campaigns delivered straight to WhatsApp.',
   '["Daily question schedules", "Scores and leaderboards", "Opt-in and opt-out handling"]'::jsonb, 5),
  ('web-portals-dashboards', 'Web Portals & Dashboards', 'web',
   'Fast, mobile-friendly websites, customer portals and admin dashboards connected to your WhatsApp workflows.',
   '["Responsive web apps", "OTP sign-in", "Reports and admin controls"]'::jsonb, 6)
) AS v(slug, name, channel, summary, features, display_order)
WHERE NOT EXISTS (SELECT 1 FROM quickinfo_services);

/* ════════════════════════════════════════════════════════ privacy policy */

INSERT INTO quickinfo_privacy_policy (display_order, title, description)
SELECT * FROM (VALUES
(1, 'About This Policy',
$t$This Privacy Policy explains how QuickInfo collects, uses, shares, stores and protects personal data when you visit our website, contact us, or use our WhatsApp based and web based solutions.

It is written to meet the requirements of the Digital Personal Data Protection Act, 2023 and the Information Technology Act, 2000, together with the rules made under them. By using QuickInfo you acknowledge that you have read this policy.$t$),

(2, 'Who We Are',
$t$QuickInfo is a software-as-a-service (SaaS) platform operated by ServerPe App Solutions, a sole proprietorship based in India ("we", "us", "our").

For personal data we collect for our own purposes, such as enquiries, accounts and billing, we are the Data Fiduciary under the Digital Personal Data Protection Act, 2023.$t$),

(3, 'Information We Collect',
$t$We collect only what we need to provide and improve our services:

• Information you give us: your name, mobile number, email address, business name, the solution you are interested in and the content of your messages.
• Information from WhatsApp: your WhatsApp number, WhatsApp profile name, the messages and media you send to a QuickInfo business number, and message delivery and read status.
• Information collected automatically on our website: IP address, browser and device type, operating system, pages visited and timestamps.
• Payment information: when you pay, the payment is processed by a licensed payment gateway. We receive the transaction reference, amount and status. We never see or store your card details, UPI PIN or net-banking password.$t$),

(4, 'Data We Process for Business Customers',
$t$Businesses use QuickInfo to serve their own customers, for example to send alerts, take bookings or answer questions on WhatsApp. For that data, the business is the Data Fiduciary and we act as its Data Processor.

We process such data only on the business's instructions and only to deliver the service it has subscribed to. The business is responsible for obtaining valid consent from its customers, including opt-in to WhatsApp messages. Questions about such data should be sent to the business concerned first.$t$),

(5, 'How We Use Your Information',
$t$We use personal data to:

• respond to your enquiries and provide quotes;
• set up, run and support the solutions you subscribe to;
• send service messages such as confirmations, alerts, reminders and OTPs;
• process payments, issue invoices and keep accounting records;
• keep our platform secure and prevent fraud, spam and misuse;
• understand usage and improve our services; and
• meet our legal and regulatory obligations.

We do not sell your personal data, and we do not use it for any purpose that is incompatible with the purpose for which it was collected.$t$),

(6, 'Consent and Withdrawal',
$t$We process your personal data on the basis of your consent, or for legitimate uses permitted by law such as responding to a request you make or meeting a legal obligation.

You can withdraw consent at any time by contacting us through the Contact Us page. Withdrawal does not affect processing already carried out, but we may no longer be able to provide services that depend on that data.$t$),

(7, 'WhatsApp Communications',
$t$We message you on WhatsApp only when you have contacted us there first or have opted in, for example by ticking the WhatsApp consent box on our contact form. Messages we start are sent using templates approved by Meta.

You can stop WhatsApp messages at any time by replying STOP or by contacting us. WhatsApp is provided by Meta Platforms, Inc., which processes message data under its own privacy policy and terms. We are not responsible for how Meta handles data on its platform.$t$),

(8, 'Sharing Your Information',
$t$We share personal data only with parties who need it to deliver our services, under contracts that require them to protect it:

• the WhatsApp Business Platform (Meta) for sending and receiving WhatsApp messages;
• cloud hosting, database, email and SMS providers;
• payment gateways for processing payments; and
• government or law-enforcement authorities when required by law, court order or to protect rights and safety.

If our business is transferred or restructured, personal data may be transferred to the successor under the same protections.$t$),

(9, 'Cookies and Local Storage',
$t$Our website uses essential cookies and browser storage to keep it working, remember your preferences and keep it secure. We may use basic analytics to understand how pages are used.

You can block or delete cookies in your browser settings, but some parts of the website may not work properly without them.$t$),

(10, 'Data Security',
$t$We use reasonable security practices to protect personal data, including encrypted connections (HTTPS), encrypted API responses, access controls, rate limiting and limited staff access on a need-to-know basis.

No system is completely secure. If a personal data breach occurs, we will notify affected users and the Data Protection Board of India as required by law.$t$),

(11, 'Data Retention',
$t$We keep personal data only for as long as it is needed for the purpose it was collected, or for as long as the law requires, for example tax and accounting records.

When data is no longer needed, or when you ask us to erase it and no legal reason requires us to keep it, we delete it or anonymise it.$t$),

(12, 'Your Rights',
$t$Under the Digital Personal Data Protection Act, 2023 you have the right to:

• obtain a summary of the personal data we process about you and how we process it;
• correct, complete or update inaccurate or incomplete data;
• erase personal data that is no longer needed;
• withdraw consent at any time;
• have your grievance addressed by us; and
• nominate another person to exercise your rights in the event of your death or incapacity.

To exercise any right, contact us through the Contact Us page. We may need to verify your identity before acting on a request.$t$),

(13, 'Children''s Privacy',
$t$QuickInfo is intended for users aged 18 and above. Where a solution is designed for children or students, it is offered to parents, guardians or institutions, and we process a child's data only with verifiable consent from a parent or lawful guardian.

We do not track, profile or target advertising at children. If you believe a child has given us personal data without such consent, please contact us so we can delete it.$t$),

(14, 'Third-Party Links',
$t$Our website and messages may link to third-party websites or services, such as payment pages. We are not responsible for their content or privacy practices, so please read their privacy policies before sharing information with them.$t$),

(15, 'Changes to This Policy',
$t$We may update this policy as our services or the law change. The "Last updated" date at the top of this page shows when it last changed.

For significant changes we will give notice on our website or through the channel you use with us. Continuing to use QuickInfo after an update means you accept the updated policy.$t$),

(16, 'Grievance Redressal and Contact',
$t$If you have a question, request or complaint about your personal data, contact us through the Contact Us page on this website and choose the "Complaint" query type.

Grievance Officer: [NAME], ServerPe App Solutions
Email: [GRIEVANCE EMAIL]

We will acknowledge your grievance and resolve it within the time required by applicable law. If you are not satisfied with our response, you may approach the Data Protection Board of India.$t$)
) AS v(display_order, title, description)
WHERE NOT EXISTS (SELECT 1 FROM quickinfo_privacy_policy);

/* ══════════════════════════════════════════════════ terms and conditions */

INSERT INTO quickinfo_terms_conditions (display_order, title, description)
SELECT * FROM (VALUES
(1, 'Acceptance of Terms',
$t$These Terms and Conditions ("Terms") govern your access to and use of QuickInfo, including our website, WhatsApp based solutions and web based solutions (together, the "Services").

By using the Services you agree to these Terms and to our Privacy Policy. If you do not agree, please do not use the Services.$t$),

(2, 'About QuickInfo',
$t$QuickInfo is a software-as-a-service (SaaS) platform operated by ServerPe App Solutions, a sole proprietorship based in India. QuickInfo provides digital solutions delivered over WhatsApp and the web, such as information bots, alerts and reminders, bookings and digital tickets, payment collection, engagement campaigns, and web portals.$t$),

(3, 'Eligibility',
$t$You must be at least 18 years old and able to enter into a legally binding contract under Indian law to use the Services. If you use the Services on behalf of a business or organisation, you confirm that you are authorised to accept these Terms on its behalf.$t$),

(4, 'Scope of Services',
$t$The features, limits and price of each solution are described on our website, in the plan you choose or in a written quote we provide. If a quote or signed agreement conflicts with these Terms, the quote or agreement prevails for that engagement.

We may add, change or remove features to improve the Services. If a change materially reduces a paid feature you are using, we will tell you in advance where reasonably possible.$t$),

(5, 'Accounts and Security',
$t$Some Services require you to sign in with a mobile number and a one-time password (OTP). You are responsible for keeping your device, WhatsApp account and login details secure, and for all activity under your account.

Tell us immediately if you suspect unauthorised use of your account.$t$),

(6, 'WhatsApp Usage',
$t$WhatsApp based Services run on the WhatsApp Business Platform provided by Meta and are also subject to WhatsApp's Business Terms, Business Policy and Commerce Policy.

If you are a business customer, you must obtain valid opt-in consent from every person you message through QuickInfo, honour opt-out requests promptly and send only lawful, relevant content. Meta may restrict, rate-limit or suspend WhatsApp numbers or message templates at its own discretion. We are not responsible for such actions or for any charges Meta applies.$t$),

(7, 'Your Content and Data',
$t$You keep ownership of the content and data you or your customers provide through the Services. You grant us a limited licence to host, process and transmit that content only as needed to provide the Services.

You confirm that you have all rights and consents needed for that content, and that it does not infringe any law or third-party right.$t$),

(8, 'Acceptable Use',
$t$You must not use the Services to:

• send spam, unsolicited bulk messages or messages to people who have not opted in;
• share unlawful, misleading, defamatory, obscene, hateful or infringing content;
• commit fraud, phishing or impersonation;
• attempt to gain unauthorised access to, overload, disrupt or reverse engineer the platform; or
• breach any applicable law, including the Information Technology Act, 2000 and the Digital Personal Data Protection Act, 2023.$t$),

(9, 'Fees, Billing and Taxes',
$t$Fees are as shown on our website, in your selected plan or in your quote. Prices are in Indian Rupees and are exclusive of GST and other applicable taxes unless stated otherwise.

Payments are processed by third-party payment gateways. Third-party usage charges, such as WhatsApp conversation charges, are billed as described in your plan or quote. We may revise prices for future billing periods with prior notice; continuing to use the Services after the revision takes effect means you accept it.$t$),

(10, 'Refunds and Cancellations',
$t$Unless your plan or quote says otherwise, fees for Services that have been activated or delivered are non-refundable.

You may stop a subscription from renewing at any time; you will keep access until the end of the period already paid for. If a payment fails but money is debited from your account, the payment gateway normally reverses it within 5 to 7 business days.$t$),

(11, 'Availability and Third-Party Services',
$t$We aim to keep the Services available and reliable, but we do not guarantee uninterrupted or error-free operation. The Services depend on third parties such as Meta (WhatsApp), hosting providers, telecom operators, SMS and email providers, data sources and payment gateways.

We are not responsible for delays, failures or inaccuracies caused by those third parties, or by scheduled maintenance, network problems or events beyond our reasonable control.$t$),

(12, 'Information Accuracy',
$t$Information delivered through QuickInfo, including alerts, reminders and look-up results, is provided for convenience and general information. Where it comes from third-party sources we cannot guarantee that it is complete, accurate or current, and it is not an official, legal or government record.

Please verify important information independently before acting on it.$t$),

(13, 'Intellectual Property',
$t$The QuickInfo platform, software, design, logos and content (excluding your content) are owned by ServerPe App Solutions or its licensors and are protected by law. You may use them only as part of your lawful use of the Services. You must not copy, modify, resell or create derivative works from them without our written permission.$t$),

(14, 'Privacy',
$t$Our Privacy Policy explains how we collect and use personal data. By using the Services you agree that we may process data as described in it.$t$),

(15, 'Disclaimer of Warranties',
$t$To the extent permitted by law, the Services are provided "as is" and "as available", without warranties of any kind, whether express or implied, including fitness for a particular purpose.$t$),

(16, 'Limitation of Liability',
$t$To the extent permitted by law, we are not liable for any indirect, incidental, special or consequential loss, or for any loss of profit, revenue, data or goodwill, or for any penalty or missed action arising from reliance on the Services.

Our total liability for any claim relating to the Services is limited to the amount you paid us for the specific Service giving rise to the claim during the [THREE] months before the claim arose.$t$),

(17, 'Indemnity',
$t$You agree to indemnify ServerPe App Solutions against claims, losses and expenses, including reasonable legal fees, arising from your breach of these Terms, your content, or your misuse of the Services, including messages you send to your customers through QuickInfo.$t$),

(18, 'Suspension and Termination',
$t$We may suspend or terminate your access, with or without notice, if you breach these Terms, if required by law or by Meta, or if your use puts the platform or other users at risk.

You may stop using the Services at any time. Sections that by their nature should survive termination, such as fees owed, intellectual property, limitation of liability, indemnity and governing law, will continue to apply.$t$),

(19, 'Changes to These Terms',
$t$We may update these Terms from time to time. The "Last updated" date at the top of this page shows when they last changed. Continuing to use the Services after an update means you accept the updated Terms.$t$),

(20, 'Governing Law and Disputes',
$t$These Terms are governed by the laws of India. We will first try to resolve any dispute amicably. If that fails, the courts at [CITY], India will have exclusive jurisdiction.$t$),

(21, 'Contact Us',
$t$For questions about these Terms, contact us through the Contact Us page on this website.$t$)
) AS v(display_order, title, description)
WHERE NOT EXISTS (SELECT 1 FROM quickinfo_terms_conditions);

COMMIT;

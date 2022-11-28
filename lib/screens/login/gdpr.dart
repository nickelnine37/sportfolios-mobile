import 'package:flutter/material.dart';

class PrivacyPolicy extends StatelessWidget {
  PrivacyPolicy();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 10),
                Text(
                  'Pricvacy Notice',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 10),
                Text('Last updated July 30, 2021'),
                SizedBox(height: 20),
                Text(
                  'Thank you for choosing to be part of our community at Betfolios Ltd ("Company", "we", "us", "our"). We are committed to protecting your personal information and your right to privacy. If you have any questions or concerns about this privacy notice, or our practices with regards to your personal information, please contact us at admin@sportfolios.co.uk.',
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 20),
                Text(
                  'When you use our mobile application, as the case may be (the "App") and more generally, use any of our services (the "Services", which include the App), we appreciate that you are trusting us with your personal information. We take your privacy very seriously. In this privacy notice, we seek to explain to you in the clearest way possible what information we collect, how we use it and what rights you have in relation to it. We hope you take some time to read through it carefully, as it is important. If there are any terms in this privacy notice that you do not agree with, please discontinue use of our Services immediately.',
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 20),
                Text(
                  'This privacy notice applies to all information collected through our Services (which, as described above, includes our App), as well as, any related services, sales, marketing or events.',
                  textAlign: TextAlign.justify,
                ),
                SizedBox(height: 20),
                Text(
                  'Please read this privacy notice carefully as it will help you understand what we do with the information that we collect.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 20),
                Text(
                  'Table of Contents',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('1. What information do we collect?', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Text('2. How do we use your information?', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Text('3. Will your information be shared with anyone?', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Text('4. How long do we keep your information?', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Text('5. How do we keep your information safe?', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Text('6. Do we collect information from minors?', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Text('7. What are your privacy rights?', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Text('8. Controls for do-not-track features', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Text('9. Do California residents have specific privacy rights?', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Text('10. Do we make updates to this notice?', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Text('11. How can you contact us about this notice?', style: TextStyle(fontWeight: FontWeight.w600)),
                    SizedBox(height: 10),
                    Text('12. How can you review, update or delete the data we collect from you?',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 30),
                Text(
                  '1. What information do we collect?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                RichText(
                    text: TextSpan(style: TextStyle(color: Colors.grey[900]), children: [
                  TextSpan(
                    style: TextStyle(fontStyle: FontStyle.italic),
                    children: [
                      TextSpan(text: 'In short: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: 'We collect personal information that you provide to us.\n\n'),
                    ],
                  ),
                  TextSpan(children: [
                    TextSpan(
                        text:
                            'We collect personal information that you voluntarily provide to us when you register on the App, express an interest in obtaining information about us or our products and Services, when you participate in activities on the App (such as by posting messages in our online forums or entering competitions, contests or giveaways) or otherwise when you contact us.\n\n'),
                    TextSpan(
                        text:
                            'The personal information that we collect depends on the context of your interactions with us and the App, the choices you make and the products and features you use. The personal information we collect may include the following: \n\n'),
                    TextSpan(text: 'Personal Information Provided by You. ', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(text: 'We collect names; email addresses; usernames; passwords; and other similar information.\n\n'),
                    TextSpan(
                        text:
                            'All personal information that you provide to us must be true, complete and accurate, and you must notify us of any changes to such personal information.')
                  ])
                ])),
                SizedBox(height: 30),
                Text(
                  '2. How do we use your information?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[800]),
                    children: [
                      TextSpan(
                        style: TextStyle(fontStyle: FontStyle.italic),
                        children: [
                          TextSpan(text: 'In short: ', style: TextStyle(fontWeight: FontWeight.w600)),
                          TextSpan(
                              text:
                                  ' We process your information for purposes based on legitimate business interests, the fulfillment of our contract with you, compliance with our legal obligations, and/or your consent.\n\n'),
                        ],
                      ),
                      TextSpan(
                          text:
                              'We use personal information collected via our App for a variety of business purposes described below. We process your personal information for these purposes in reliance on our legitimate business interests, in order to enter into or perform a contract with you, with your consent, and/or for compliance with our legal obligations. We indicate the specific processing grounds we rely on next to each purpose listed below. \n\n We use the information we collect or receive: \n\n '),
                      TextSpan(text: 'To facilitate account creation and logon process.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              ' If you choose to link your account with us to a third-party account (such as your Google or Facebook account), we use the information you allowed us to collect from those third parties to facilitate account creation and logon process for the performance of the contract.\n\n'),
                      TextSpan(text: 'To post testimonials.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              ' We post testimonials on our App that may contain personal information  Prior to posting a testimonial, we will obtain your consent to use your name and the content of the testimonial  If you wish to update, or delete your testimonial, please contact us at admin@sportfolios co uk and be sure to include your name, testimonial location, and contact information.\n\n'),
                      TextSpan(text: 'Request feedback.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: ' We may use your information to request feedback and to contact you about your use of our App.\n\n'),
                      TextSpan(text: 'To enable user-to-user communications.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              ' We may use your information in order to enable user-to-user communications with each user\'s consent.\n\n'),
                      TextSpan(text: 'To manage user accounts.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              ' We may use your information for the purposes of managing our account and keeping it in working order.\n\n'),
                      TextSpan(text: 'To send administrative information to you.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              ' We may use your personal information to send you product, service and new feature information and/or information about changes to our terms, conditions, and policies.\n\n'),
                      TextSpan(text: 'To protect our Services.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              ' We may use your information as part of our efforts to keep our App safe and secure (for example, for fraud monitoring and prevention).\n\n'),
                      TextSpan(
                          text:
                              'To enforce our terms, conditions and policies for business purposes, to comply with legal and regulatory requirements or in connection with our contract.',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: '.\n\n'),
                      TextSpan(text: 'To respond to legal requests and prevent harm.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              ' If we receive a subpoena or other legal request, we may need to inspect the data we hold to determine how to respond.\n\n'),
                      TextSpan(text: 'Fulfill and manage your orders.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              ' We may use your information to fulfill and manage your orders, payments, returns, and exchanges made through the App.\n\n'),
                      TextSpan(text: 'Administer prize draws and competitions.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              ' We may use your information to administer prize draws and competitions when you elect to participate in our competitions.\n\n'),
                      TextSpan(
                          text: 'To deliver and facilitate delivery of services to the user.',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: ' We may use your information to provide you with the requested service.\n\n'),
                      TextSpan(text: 'To respond to user inquiries/offer support to users.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              ' We may use your information to respond to your inquiries and solve any potential issues you might have with the use of our Services.\n\n'),
                      TextSpan(
                          text: 'To send you marketing and promotional communications.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              ' We and/or our third-party marketing partners may use the personal information you send to us for our marketing purposes, if this is in accordance with your marketing preferences  For example, when expressing an interest in obtaining information about us or our App, subscribing to marketing or otherwise contacting us, we will collect personal information from you  You can opt-out of our marketing emails at any time (see section 7 "What are your privacy rights?" below).\n\n'),
                      TextSpan(text: 'Deliver targeted advertising to you.', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              ' We may use your information to develop and display personalized content and advertising (and work with third parties who do so) tailored to your interests and/or location and to measure its effectiveness.\n\n'),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  '3. Will your information be shared with anyone?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                RichText(
                  text: TextSpan(style: TextStyle(color: Colors.grey[800]), children: [
                    TextSpan(
                      style: TextStyle(fontStyle: FontStyle.italic),
                      children: [
                        TextSpan(text: 'In short: ', style: TextStyle(fontWeight: FontWeight.w600)),
                        TextSpan(
                            text:
                                'We only share information with your consent, to comply with laws, to provide you with services, to protect your rights, or to fulfill business obligations.\n\n'),
                      ],
                    ),
                    TextSpan(text: 'We may process or share your data that we hold based on the following legal basis: \n\n'),
                    TextSpan(text: 'Consent:', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(
                        text:
                            ' We may process your data if you have given us specific consent to use your personal information for a specific purpose.\n\n'),
                    TextSpan(text: 'Legitimate Interests:', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(
                        text:
                            ' We may process your data when it is reasonably necessary to achieve our legitimate business interests.\n\n'),
                    TextSpan(text: 'Performance of a Contract:', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(
                        text:
                            ' Where we have entered into a contract with you, we may process your personal information to fulfill the terms of our contract.\n\n'),
                    TextSpan(text: 'Legal Obligations:', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(
                        text:
                            ' We may disclose your information where we are legally required to do so in order to comply with applicable law, governmental requests, a judicial proceeding, court order, or legal process, such as in response to a court order or a subpoena (including in response to public authorities to meet national security or law enforcement requirements).\n\n'),
                    TextSpan(text: 'Vital Interests:', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(
                        text:
                            ' We may disclose your information where we believe it is necessary to investigate, prevent, or take action regarding potential violations of our policies, suspected fraud, situations involving potential threats to the safety of any person and illegal activities, or as evidence in litigation in which we are involved.\n\n'),
                    TextSpan(
                        text:
                            'More specifically, we may need to process your data or share your personal information in the following situations:\n\n'),
                    TextSpan(text: 'Business Transfers.', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(
                        text:
                            ' We may share or transfer your information in connection with, or during negotiations of, any merger, sale of company assets, financing, or acquisition of all or a portion of our business to another company.\n\n'),
                    TextSpan(text: 'Other Users.', style: TextStyle(fontWeight: FontWeight.w600)),
                    TextSpan(
                        text:
                            ' When you share personal information (for example, by posting comments, contributions or other content to the App) or otherwise interact with public areas of the App, such personal information may be viewed by all users and may be publicly made available outside the App in perpetuity  Similarly, other users will be able to view descriptions of your activity, communicate with you within our App, and view your profile.'),
                  ]),
                ),
                SizedBox(height: 30),
                Text(
                  '4. How long do we keep your information?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                RichText(
                    text: TextSpan(style: TextStyle(color: Colors.grey[800]), children: [
                  TextSpan(
                    style: TextStyle(fontStyle: FontStyle.italic),
                    children: [
                      TextSpan(text: 'In short: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              'We keep your information for as long as necessary to fulfill the purposes outlined in this privacy notice unless otherwise required by law.\n\n'),
                    ],
                  ),
                  TextSpan(
                      text:
                          'We will only keep your personal information for as long as it is necessary for the purposes set out in this privacy notice, unless a longer retention period is required or permitted by law (such as tax, accounting or other legal requirements). No purpose in this notice will require us keeping your personal information for longer than the period of time in which users have an account with us.\n\nWhen we have no ongoing legitimate business need to process your personal information, we will either delete or anonymize such information, or, if this is not possible (for example, because your personal information has been stored in backup archives), then we will securely store your personal information and isolate it from any further processing until deletion is possible.')
                ])),
                SizedBox(height: 30),
                Text(
                  '5. How do we keep your information safe?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                RichText(
                    text: TextSpan(style: TextStyle(color: Colors.grey[800]), children: [
                  TextSpan(
                    style: TextStyle(fontStyle: FontStyle.italic),
                    children: [
                      TextSpan(text: 'In short: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              'We aim to protect your personal information through a system of organizational and technical security measures.\n\n'),
                    ],
                  ),
                  TextSpan(
                      text:
                          'We have implemented appropriate technical and organizational security measures designed to protect the security of any personal information we process. However, despite our safeguards and efforts to secure your information, no electronic transmission over the Internet or information storage technology can be guaranteed to be 100% secure, so we cannot promise or guarantee that hackers, cybercriminals, or other unauthorized third parties will not be able to defeat our security, and improperly collect, access, steal, or modify your information. Although we will do our best to protect your personal information, transmission of personal information to and from our App is at your own risk. You should only access the App within a secure environment.')
                ])),
                SizedBox(height: 30),
                Text(
                  '6. Do we collect information from minors?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                RichText(
                    text: TextSpan(style: TextStyle(color: Colors.grey[800]), children: [
                  TextSpan(
                    style: TextStyle(fontStyle: FontStyle.italic),
                    children: [
                      TextSpan(text: 'In short: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: 'We do not knowingly collect data from or market to children under 18 years of age.\n\n'),
                    ],
                  ),
                  TextSpan(
                      text:
                          'We do not knowingly solicit data from or market to children under 18 years of age. By using the App, you represent that you are at least 18 or that you are the parent or guardian of such a minor and consent to such minor dependent\'s use of the App. If we learn that personal information from users less than 18 years of age has been collected, we will deactivate the account and take reasonable measures to promptly delete such data from our records. If you become aware of any data we may have collected from children under age 18, please contact us at admin@sportfolios.co.uk.')
                ])),
                SizedBox(height: 30),
                Text(
                  '7. What are your privacy rights?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                RichText(
                    text: TextSpan(style: TextStyle(color: Colors.grey[800]), children: [
                  TextSpan(
                    style: TextStyle(fontStyle: FontStyle.italic),
                    children: [
                      TextSpan(text: 'In short: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              'In some regions, such as the European Economic Area (EEA) and United Kingdom (UK), you have rights that allow you greater access to and control over your personal information. You may review, change, or terminate your account at any time. \n\n'),
                    ],
                  ),
                  TextSpan(
                      text:
                          'In some regions (like the EEA and UK), you have certain rights under applicable data protection laws. These may include the right (i) to request access and obtain a copy of your personal information, (ii) to request rectification or erasure; (iii) to restrict the processing of your personal information; and (iv) if applicable, to data portability. In certain circumstances, you may also have the right to object to the processing of your personal information. To make such a request, please use the contact details provided below. We will consider and act upon any request in accordance with applicable data protection laws.\n\n If we are relying on your consent to process your personal information, you have the right to withdraw your consent at any time. Please note however that this will not affect the lawfulness of the processing before its withdrawal, nor will it affect the processing of your personal information conducted in reliance on lawful processing grounds other than consent. \n\n If you are a resident in the EEA or UK and you believe we are unlawfully processing your personal information, you also have the right to complain to your local data protection supervisory authority. You can find their contact details here: http://ec.europa.eu/justice/data-protection/bodies/authorities/index_en.htm. \n\n If you are a resident in Switzerland, the contact details for the data protection authorities are available here: https://www.edoeb.admin.ch/edoeb/en/home.html. \n\n If you have questions or comments about your privacy rights, you may email us at admin@sportfolios.co.uk. \n\n If you would at any time like to review or change the information in your account or terminate your account, you can contact us using the contact information provided. \n\n Upon your request to terminate your account, we will deactivate or delete your account and information from our active databases. However, we may retain some information in our files to prevent fraud, troubleshoot problems, assist with any investigations, enforce our Terms of Use and/or comply with applicable legal requirements. \n\n You can unsubscribe from our marketing email list at any time by clicking on the unsubscribe link in the emails that we send or by contacting us using the details provided below. You will then be removed from the marketing email list â€” however, we may still communicate with you, for example to send you service-related emails that are necessary for the administration and use of your account, to respond to service requests, or for other non-marketing purposes. To otherwise opt-out, you may contact us using the contact information provided.')
                ])),
                SizedBox(height: 30),
                Text(
                  '8. Controls for do-not-track features',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                RichText(
                    text: TextSpan(style: TextStyle(color: Colors.grey[800]), children: [
                  TextSpan(
                      text:
                          'Most web browsers and some mobile operating systems and mobile applications include a Do-Not-Track ("DNT") feature or setting you can activate to signal your privacy preference not to have data about your online browsing activities monitored and collected. At this stage no uniform technology standard for recognizing and implementing DNT signals has been finalized. As such, we do not currently respond to DNT browser signals or any other mechanism that automatically communicates your choice not to be tracked online. If a standard for online tracking is adopted that we must follow in the future, we will inform you about that practice in a revised version of this privacy notice. ')
                ])),
                SizedBox(height: 30),
                Text(
                  '9. Do California residents have specific privacy rights?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                RichText(
                    text: TextSpan(style: TextStyle(color: Colors.grey[800]), children: [
                  TextSpan(
                    style: TextStyle(fontStyle: FontStyle.italic),
                    children: [
                      TextSpan(text: 'In short: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(
                          text:
                              'Yes, if you are a resident of California, you are granted specific rights regarding access to your personal information.\n\n'),
                    ],
                  ),
                  TextSpan(
                    text:
                        'California Civil Code Section 1798.83, also known as the "Shine The Light" law, permits our users who are California residents to request and obtain from us, once a year and free of charge, information about categories of personal information (if any) we disclosed to third parties for direct marketing purposes and the names and addresses of all third parties with which we shared personal information in the immediately preceding calendar year. If you are a California resident and would like to make such a request, please submit your request in writing to us using the contact information provided below. \n\n If you are under 18 years of age, reside in California, and have a registered account with the App, you have the right to request removal of unwanted data that you publicly post on the App. To request removal of such data, please contact us using the contact information provided below, and include the email address associated with your account and a statement that you reside in California. We will make sure the data is not publicly displayed on the App, but please be aware that the data may not be completely or comprehensively removed from all our systems (e.g. backups, etc.).',
                  )
                ])),
                SizedBox(height: 30),
                Text(
                  '10. Do we make updates to this notice?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                RichText(
                    text: TextSpan(style: TextStyle(color: Colors.grey[800]), children: [
                  TextSpan(
                    style: TextStyle(fontStyle: FontStyle.italic),
                    children: [
                      TextSpan(text: 'In short: ', style: TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: 'Yes, we will update this notice as necessary to stay compliant with relevant laws. \n\n'),
                    ],
                  ),
                  TextSpan(
                      text:
                          'We may update this privacy notice from time to time. The updated version will be indicated by an updated "Revised" date and the updated version will be effective as soon as it is accessible. If we make material changes to this privacy notice, we may notify you either by prominently posting a notice of such changes or by directly sending you a notification. We encourage you to review this privacy notice frequently to be informed of how we are protecting your information.')
                ])),
                SizedBox(height: 30),
                Text(
                  '11. How can you contact us about this notice?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                RichText(
                    text: TextSpan(style: TextStyle(color: Colors.grey[800]), children: [
                  TextSpan(
                      text:
                          'If you have questions or comments about this notice, you may email us at admin@sportfolios.co.uk or by post to: \n\nBetfolios Ltd, \n2/7 Lower Gilmore Bank,\nEdinburgh,\nEH3 9QP')
                ])),
                SizedBox(height: 30),
                Text(
                  '12. How can you review, update or delete the data we collect from you?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                ),
                SizedBox(height: 20),
                RichText(
                    text: TextSpan(style: TextStyle(color: Colors.grey[800]), children: [
                  TextSpan(
                      text:
                          'Based on the applicable laws of your country, you may have the right to request access to the personal information we collect from you, change that information, or delete it in some circumstances. To request to review, update, or delete your personal information, please visit: admin@sportfolios.co.uk.')
                ])),
                SizedBox(height: 50),
              ],
            ),
          ),
        ));
  }
}

<?php

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    exit;
}

if (! filter_var($_POST['email'], FILTER_VALIDATE_EMAIL)) {
    exit;
}

$mailer_option = 'swiftmailer'; // or 'php-mailer'

if ($mailer_option == 'swiftmailer') {
    $smtp_host = 'mail.yourdomain.com'; // Your SMTP host domain
    $smtp_port = 25; // Your SMTP host port
    $smtp_user = 'you@yourdomain.com'; // Your e-mail account to send from
    $smtp_pass = 'your-password'; // Your e-mail account password to send from

    $to_email  = 'send-to@me.com'; // The e-mail to send the message to.
    $website   = '[Website]'; // Your website's name

    require 'swiftmailer/lib/swift_required.php';

    $transport = Swift_SmtpTransport::newInstance($smtp_host, $smtp_port)
        ->setUsername($smtp_user)
        ->setPassword($smtp_pass)
    ;

    $mailer = Swift_Mailer::newInstance($transport);

    $message = Swift_Message::newInstance()
        ->setSubject($subject)
        ->setFrom(array($smtp_user => $website))
        ->setTo(array($to_email))
        ->setBody($_POST['email'])
    ;

    $mailer->send($message);
} else {
    $to_email  = 'send-to@me.com'; // The e-mail to send the message to.
    $website   = '[Website]'; // Your website's name

    mail($to_email, $website, $_POST['email']);
}

$message_to_user = 'Thank you for signing up!';

header('Content-Type: text/plain');
print $message_to_user;
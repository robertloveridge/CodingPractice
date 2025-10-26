<?php
require_once('xmlrpc.inc');

$account = 'example';
$username = 'example';
$password = 'example';

$xmlrpc = new xmlrpc_client("https://$account.$username:$password@app.adestra.com/api/xmlrpc");
$xmlrpc->setDebug(1);

// campaign.create
// campaign.setAllOptions
// campaign.setMessage
// campaign.publish
// campaign.launch

// Create a new campaign
// Documentation: http://app.adestra.com/doc/page/current/index/api/campaign#campaign-create
$new_campaign_args = new xmlrpcmsg(
    "campaign.create",
    array(
        new xmlrpcval(
          array(
            // campaign name
            "name" => new xmlrpcval("Weekly Newsletter", "string"),

            // description
            "description" => new xmlrpcval("This is our weekly newsletter, volume #37.", "string"),

            // it should be owned by user id 9
            "owner_user_id" => new xmlrpcval(9, "int"),

            // we want the campaign to be in project id 86
            "project_id" => new xmlrpcval(86, "int"),

            // list id 2285 has our contacts, so assign that
            "list_id" => new xmlrpcval(2285, "int")
          ),
        "struct")
    )
);

// send the call and return the new campaign data
$new_campaign_request = $xmlrpc->send($new_campaign_args);
$new_campaign = php_xmlrpc_decode($new_campaign_request->value());

// Set the campaign options
// Documentation: http://app.adestra.com/doc/page/current/index/api/campaign#campaign-setAllOptions
$campaign_options_args = new xmlrpcmsg(
    "campaign.setAllOptions",
    array(
      // campaign_id
      new xmlrpcval($new_campaign["id"], "int"),

      // some options, you can add more to the array but the example only shows 3
      new xmlrpcval(
        array(
          // the subject line for our campaign
          "subject_line" => new xmlrpcval("Our weekly newsletter!!", "string"),

          // a valid delegated domain
          "domain" => new xmlrpcval("newsletter.robertloveridge.co.uk", "string"),

          // unsub list id 201
          "unsub_list" => new xmlrpcval(201, "int"),

          // from name
          "from_name" => new xmlrpcval("Robert Loveridge", "string"),

          // from prefix
          "from_prefix" => new xmlrpcval("mail", "string")
        ),
      "struct")
    )
);

// send the call, result not captured
$xmlrpc->send($campaign_options_args);

// Add some HTML
//Documentation: http://app.adestra.com/doc/page/current/index/api/campaign#campaign-setMessage
$html_message_args = new xmlrpcmsg(
  "campaign.setMessage",
  array(
    // campaign_id
    new xmlrpcval($new_campaign["id"], "int"),

    // html content type
    new xmlrpcval("html", "string"),

    // html source for the campaign
    new xmlrpcval("<h1>Hello World</h1>", "string")
  )
);

// send the call, result not captured
$xmlrpc->send($html_message_args);

// publish the campaign
//Documentation: http://app.adestra.com/doc/page/current/index/api/campaign#campaign-publish
$publish_args = new xmlrpcmsg(
  "campaign.publish",
  array(
    new xmlrpcval($new_campaign["id"], "int")
  )
);

// send the call, result not captured
$xmlrpc->send($publish_args);

// launch the campaign
//Documentation: http://app.adestra.com/doc/page/current/index/api/campaign#campaign-launch
$launch_args = new xmlrpcmsg(
  "campaign.launch",
  array(
    new xmlrpcval($new_campaign["id"], "int")
  )
);

// send the call, result not captured
$xmlrpc->send($launch_args);
?>

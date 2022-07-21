ruleset com.tcashcroft.helloworld-app {
  meta {
    name "Hellos"
    use module io.picolabs.wrangler alias wrangler
    use module html.byu alias html
    shares Hello
  }
  global {
    event_domain = "com_tcashcroft_helloworld_app"
    Hello = function(_headers){
      html:header("manage Hellos","",null,null,_headers)
      + <<
<h1>Manage Hellos</h1>
<p>
Hello, #{ent:name}!
</p>
>>
      + html:footer()
    }
  }
  rule initialize {
    select when wrangler ruleset_installed where event:attr("rids") >< meta:rid
    every {
      wrangler:createChannel(
        ["Hellos"],
        {"allow":[{"domain":event_domain,"name":"*"}],"deny":[]},
        {"allow":[{"rid":meta:rid,"name":"*"}],"deny":[]}
      )
    }
    fired {
      raise com_tcashcroft_helloworld_app event "factory_reset"
    }
  }
  rule keepChannelsClean {
    select when com_tcashcroft_helloworld_app factory_reset
    foreach wrangler:channels(["Hellos"]).reverse().tail() setting(chan)
    wrangler:deleteChannel(chan.get("id"))
  }
}

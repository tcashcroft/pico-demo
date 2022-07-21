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
      url = <<#{meta:host}/sky/event/#{meta:eci}/none/#{event_domain}/given_name>>
      html:header("manage Hellos","",null,null,_headers)
      + <<
<h1>Manage Hellos</h1>
<p>
Hello, #{ent:name.defaultsTo("world")}!
</p>
<h2>Technical details</h2>
<pre>#{url}</pre>
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

rule acceptAndStoreName {
  select when com_tcashcroft_helloworld-app given_name
    name re#(.+)# setting(new_val)
  fired {
    end:name := new_val
    raise com_tcashcroft_helloworld-app event "name_saved" attributes event:attrs
  }
}

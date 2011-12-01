self.PLEXMEDIASERVER_preaction = function()
{
}

self.PLEXMEDIASERVER_onloadaction = function()
{
  setTimeout(function() {
    $('#BUTTON_PLEXMEDIASERVER_UPDATE').remove();
    var plexlink = '<a href="http://' + window.location.hostname + ':32400/manage" target="_blank">Manage Plex Media Server</a>';
    $('#plexmgr').html(plexlink);
  }, 250);
}

self.PLEXMEDIASERVER_enable = function()
{
  document.getElementById('BUTTON_PLEXMEDIASERVER_APPLY').disabled = false;
  var runtimeSecs = document.getElementById('PLEXMEDIASERVER_RUNTIME_SECS');
  if (runtimeSecs)
  {
    runtimeSecs.disabled = false;
  }
}

self.PLEXMEDIASERVER_remove = function()
{
  if( !confirm(S['CONFIRM_REMOVE_ADDON']) )
  {
    return;
  }
  
  var set_url;
  
  if ( confirm(S['CONFIRM_KEEP_ADDON_DATA']) )
  {
    set_url = NasState.otherAddOnHash['PLEXMEDIASERVER'].DisplayAtom.set_url
                + '?OPERATION=set&command=RemoveAddOn&data=preserve';
  }
  else
  {
    set_url = NasState.otherAddOnHash['PLEXMEDIASERVER'].DisplayAtom.set_url
                + '?OPERATION=set&command=RemoveAddOn&data=remove';
  }

  applyChangesAsynch(set_url,  PLEXMEDIASERVER_handle_remove_response);
}

self.PLEXMEDIASERVER_handle_remove_response = function()
{
  if ( httpAsyncRequestObject && 
      httpAsyncRequestObject.readyState && 
      httpAsyncRequestObject.readyState == 4 ) 
  {
    if ( httpAsyncRequestObject.responseText.indexOf('<payload>') != -1 )
    {
       showProgressBar('default');
       xmlPayLoad  = httpAsyncRequestObject.responseXML;
       var status = xmlPayLoad.getElementsByTagName('status').item(0);
       if (!status || !status.firstChild)
       {
          return;
       }

       if ( status.firstChild.data == 'success')
       {
         display_messages(xmlPayLoad);
         updateAddOn('PLEXMEDIASERVER');
         if (!NasState.otherAddOnHash['PLEXMEDIASERVER'])
         {
            remove_element('PLEXMEDIASERVER');
            if (getNumAddOns() == 0 )
            {
               document.getElementById('no_addons').className = 'visible';
            }
         }
         else
         {
           hide_element('PLEXMEDIASERVER_LINK');
         }
       }
       else if (status.firstChild.data == 'failure')
       {
         display_error_messages(xmlPayLoad);
       }
    }
    httpAsyncRequestObject = null;
  }
}

self.PLEXMEDIASERVER_page_change = function()
{
  var id_array = new Array( 'PLEXMEDIASERVER_RUNTIME_SECS' );
  for (var ix = 0; ix < id_array.length; ix++ )
  {
     NasState.otherAddOnHash['PLEXMEDIASERVER'].DisplayAtom.fieldHash[id_array[ix]].value = 
     document.getElementById(id_array[ix]).value;
     NasState.otherAddOnHash['PLEXMEDIASERVER'].DisplayAtom.fieldHash[id_array[ix]].modified = true;
  }
}


self.PLEXMEDIASERVER_enable_save_button = function()
{
  document.getElementById('BUTTON_PLEXMEDIASERVER_APPLY').disabled = false;
}

self.PLEXMEDIASERVER_apply = function()
{

   var page_changed = false;
   var set_url = NasState.otherAddOnHash['PLEXMEDIASERVER'].DisplayAtom.set_url;
   var runtimeSecs = document.getElementById('PLEXMEDIASERVER_RUNTIME_SECS');
   if (runtimeSecs)
   {
     var id_array = new Array ('PLEXMEDIASERVER_RUNTIME_SECS');
     for (var ix = 0; ix < id_array.length ; ix ++)
     {
       if (  NasState.otherAddOnHash['PLEXMEDIASERVER'].DisplayAtom.fieldHash[id_array[ix]].modified )
       {
          page_changed = true;
          break;
       }
     }
   }
   var enabled = document.getElementById('CHECKBOX_PLEXMEDIASERVER_ENABLED').checked ? 'checked' :  'unchecked';
   var current_status  = NasState.otherAddOnHash['PLEXMEDIASERVER'].Status;
   if ( page_changed )
   {
      set_url += '?command=ModifyAddOnService&OPERATION=set&' + 
                  NasState.otherAddOnHash['PLEXMEDIASERVER'].DisplayAtom.getApplicablePagePostStringNoQuest('modify') +
                  '&CHECKBOX_PLEXMEDIASERVER_ENABLED=' +  enabled;
      if ( enabled == 'checked' && current_status == 'on' ) 
      {
        set_url += "&SWITCH=NO";
      }
      else
      {
         set_url += "&SWITCH=YES";
      }
   }
   else
   {
      set_url += '?command=ToggleService&OPERATION=set&CHECKBOX_PLEXMEDIASERVER_ENABLED=' + enabled;
   }
   applyChangesAsynch(set_url, PLEXMEDIASERVER_handle_apply_response);
}

self.PLEXMEDIASERVER_handle_apply_response = function()
{
  if ( httpAsyncRequestObject &&
       httpAsyncRequestObject.readyState &&
       httpAsyncRequestObject.readyState == 4 )
  {
    if ( httpAsyncRequestObject.responseText.indexOf('<payload>') != -1 )
    {
      showProgressBar('default');
      xmlPayLoad = httpAsyncRequestObject.responseXML;
      var status = xmlPayLoad.getElementsByTagName('status').item(0);
      if ( !status || !status.firstChild )
      {
        return;
      }

      if ( status.firstChild.data == 'success' )
      {
        var log_alert_payload = xmlPayLoad.getElementsByTagName('normal_alerts').item(0);
        if ( log_alert_payload )
	{
	  var messages = grabMessagePayLoad(log_alert_payload);
	  if ( messages && messages.length > 0 )
	  {
	      if ( messages != 'NO_ALERTS' )
	      {
	        alert (messages);
	      }
	      var success_message_start = AS['SUCCESS_ADDON_START'];
		  success_message_start = success_message_start.replace('%ADDON_NAME%', NasState.otherAddOnHash['PLEXMEDIASERVER'].FriendlyName);
	      var success_message_stop  = AS['SUCCESS_ADDON_STOP'];
		  success_message_stop = success_message_stop.replace('%ADDON_NAME%', NasState.otherAddOnHash['PLEXMEDIASERVER'].FriendlyName);

	      if ( NasState.otherAddOnHash['PLEXMEDIASERVER'].Status == 'off' )
	      {
	        NasState.otherAddOnHash['PLEXMEDIASERVER'].Status = 'on';
	        NasState.otherAddOnHash['PLEXMEDIASERVER'].RunStatus = 'OK';
	        refresh_applicable_pages();
	      }
	      else
	      {
	        NasState.otherAddOnHash['PLEXMEDIASERVER'].Status = 'off';
	        NasState.otherAddOnHash['PLEXMEDIASERVER'].RunStatus = 'not_present';
	        refresh_applicable_pages();
	      }
	    }
        }
      }
      else if (status.firstChild.data == 'failure')
      {
        display_error_messages(xmlPayLoad);
      }
    }
    httpAsyncRequestObject = null;
  }
}

self.PLEXMEDIASERVER_handle_apply_toggle_response = function()
{
  if (httpAsyncRequestObject &&
      httpAsyncRequestObject.readyState &&
      httpAsyncRequestObject.readyState == 4 )
  {
    if ( httpAsyncRequestObject.responseText.indexOf('<payload>') != -1 )
    {
      showProgressBar('default');
      xmlPayLoad = httpAsyncRequestObject.responseXML;
      var status = xmlPayLoad.getElementsByTagName('status').item(0);
      if (!status || !status.firstChild)
      {
        return;
      }
      if ( status.firstChild.data == 'success' )
      {
        display_messages(xmlPayLoad);
      }
      else
      {
        display_error_messages(xmlPayLoad);
      }
    }
  }
}

self.PLEXMEDIASERVER_service_toggle = function()
{
  
  var addon_enabled = document.getElementById('CHECKBOX_PLEXMEDIASERVER_ENABLED').checked ? 'checked' :  'unchecked';
  var set_url    = NasState.otherAddOnHash['PLEXMEDIASERVER'].DisplayAtom.set_url
                   + '?OPERATION=set&command=ToggleService&CHECKBOX_PLEXMEDIASERVER_ENABLED='
                   + addon_enabled;
  
  var xmlSyncPayLoad = getXmlFromUrl(set_url);
  var syncStatus = xmlSyncPayLoad.getElementsByTagName('status').item(0);
  if (!syncStatus || !syncStatus.firstChild)
  {
     return ret_val;
  }

  if ( syncStatus.firstChild.data == 'success' )
  {
    display_messages(xmlSyncPayLoad);
    //if PLEXMEDIASERVER is enabled
    NasState.otherAddOnHash['PLEXMEDIASERVER'].Status = 'on';                                             
    NasState.otherAddOnHash['PLEXMEDIASERVER'].RunStatus = 'OK';                                            
    refresh_applicable_pages();  
    //else if PLEXMEDIASERVER is disabled
    NasState.otherAddOnHash['PLEXMEDIASERVER'].Status = 'off';                    
    NasState.otherAddOnHash['PLEXMEDIASERVER'].RunStatus = 'not_present';         
    refresh_applicable_pages(); 
  }
  else
  {
    display_error_messages(xmlSyncPayLoad);
  }
}


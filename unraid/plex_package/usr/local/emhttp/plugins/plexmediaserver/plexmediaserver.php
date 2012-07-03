<?PHP
$plex_cfg = parse_ini_file( "/boot/config/plugins/plexmediaserver/settings.ini");
$plex_running = file_exists($plex_cfg['PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR']."/Plex Media Server/plexmediaserver.pid") ? "yes" : "no";
$plex_version = shell_exec( "/etc/rc.d/rc.plexmediaserver version" );
?>
<form name="plex_settings" method="POST" action="/plugins/plexmediaserver/plexmediaserverctl.php" target="progressFrame">
	<input type="hidden" name="RUNAS" value="<?=$plex_cfg['RUNAS'];?>">
      <table class="settings">
         <tr>
         <td>Enable Plex Media Server:</td>
         <td><select name="SERVICE" size="1"  onChange="checkPLEX_INSTALLDIR(this.form);">
            <?=mk_option($plex_cfg['ENABLED'], "false", "No");?>
            <?=mk_option($plex_cfg['ENABLED'], "true", "Yes");?>
            </select></td>
         </tr>
                 <tr>
         <td>Library directory:</td>
         <td><input type="text" name="LIBDIR" maxlength="60" value="<?=$plex_cfg['PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR'];?>"></td>
         </tr>
         <tr>
         <td>Temp directory:</td>
         <td><input type="text" name="TMPDIR" maxlength="60" value="<?=$plex_cfg['PLEX_MEDIA_SERVER_TMPDIR'];?>"></td>
         </tr>
         <tr>
         <td></td>
	 <td><input type="submit" name="runCmd" value="Apply"><button type="button" onClick="done();">Done</button></td>
         </tr>
      </table>
</form>
<div id="title"><span class="left">Status:
	<?if ($plex_running=="yes"):?>
  		<a href="http://<?=$var['IPADDR'];?>:32400/manage" target="_blank"><span class="green"><b>RUNNING</b></span></a><span> with version: <b><?=$plex_version;?></b></span>
	<?else:?>
  		<span class="red"><b>STOPPED</b></span>
	<?endif;?>
</span></div>

<script type="text/javascript">
function checkPLEX_INSTALLDIR(form)
{
   if ("<?=$plex_running;?>" == "yes") {
      form.LIBDIR.readOnly = true;
      form.TMPDIR.readOnly = true;
   }
   else {
      form.LIBDIR.readOnly = (form.SERVICE.value == "true");
      form.TMPDIR.readOnly = (form.SERVICE.value == "true");
   }
}
checkPLEX_INSTALLDIR(document.plex_settings);
</script>

<?PHP
	$pms_config_file = "/boot/config/plugins/plexmediaserver/plex_settings.cfg";
	if (empty($_SERVER['SHELL']))
    		$newline = "<br>";
  	else
    		$newline = "\n";
	
	parse_str($argv[1],$_POST);	
	
  	write_config($pms_config_file);
	
	if (empty($_SERVER['SHELL'])) {
    		echo("<html>");
    		echo("<head><script>var goback=parent.location;</script></head>");
    		echo("<body onLoad=\"parent.location=goback;\"></body>");
    		echo("</html>");
  	}

function write_config($p_file){
	$fh = fopen($p_file, 'w') or die("can't open file");
	fwrite($fh, "# plex configuration\n");
	fwrite($fh, "DEFAULT_ENABLED=\"".$_POST['SERVICE']."\"\n");
	fwrite($fh, "DEFAULT_RUNAS=\"".$_POST['RUNAS']."\"\n");
	fwrite($fh, "DEFAULT_TMPDIR=\"".$_POST['TMPDIR']."\"\n");
	fwrite($fh, "DEFAULT_PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=\"".$_POST['LIBDIR']."\"\n");
	fclose($fh);
}

?>

<?PHP
	$pms_config_file = "/boot/config/plugins/plexmediaserver/settings.ini";
	$logfile = "/var/log/plugins/plexmediaserver";
	if (empty($_SERVER['SHELL']))
    		$newline = "<br>";
  	else
    		$newline = "\n";
	
	parse_str($argv[1],$_POST);	
	
  	edit_config_file();
	
	switch ($_POST['SERVICE']){
        case "true":
                system("/etc/rc.d/rc.plexmediaserver start");
                break;
        case "false":
                exec("/etc/rc.d/rc.plexmediaserver stop");
                break;
        default:
                break;
	}
	
	if (empty($_SERVER['SHELL'])) {
    		echo("<html>");
    		echo("<head><script>var goback=parent.location;</script></head>");
    		echo("<body onLoad=\"parent.location=goback;\"></body>");
    		echo("</html>");
  	}

  function edit_config_file(){
        global $pms_config_file;
        exec_log("sed -i '/START_CONFIGURATION/,/STOP_CONFIGURATION/ {
                /ENABLED/ c\ENABLED=\"".$_POST['SERVICE']."\"
                /PLEX_MEDIA_SERVER_TMPDIR/ c\PLEX_MEDIA_SERVER_TMPDIR=\"".$_POST['TMPDIR']."\"
                /PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR/ c\PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR=\"".$_POST['LIBDIR']."\"
        }
        ' ".$pms_config_file);
  }

  function exec_log($cmd) {
    $results = exec($cmd);
    $results = "\nCMD: $cmd \nResults: $results";
    write_log($results);
  }

  function write_log($contents) {
    global $logfile;
    write_string($logfile, "$contents\n", FALSE);
  }

  function write_string ($file, $contents, $overwrite) {
    if (file_exists($file)) {
      if ($overwrite)
          unlink($file);
          touch($file);
    }
    else {
      touch($file);
    }

    $fp = @fopen($file, 'a');
    @flock($fp, LOCK_EX);
    @fwrite($fp, $contents);
    @flock($fp, LOCK_UN);
    @fclose($fp);
  }

?>

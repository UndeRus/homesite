#!/usr/bin/env perl

use Mojolicious::Lite;
use POSIX qw(strftime);
use utf8;
# Documentation browser under "/perldoc" (this plugin requires Perl 5.10)
plugin 'pod_renderer';

sub parse_cmd {
  my ($cmd) = @_;
  print $cmd;

  my @commands = ('help', 'whoami','ls', 'ls resume',);
  if ($cmd ~~ @commands) {
    if ($cmd eq "whoami") {
      return <<END;
<div>Меня зовут Kerrigan, сайт пока в разработке</div>
END
    }
    elsif ($cmd eq 'help'){
      return <<END;
List of commands: help, whoami, ls
END
    }
    elsif($cmd eq 'ls'){
      return <<END;
summary
END
    }
    elsif($cmd eq 'ls summary'){
      return "Still in development";
    }
  return($cmd);
  }
  else
    {
      return "zsh: command not found: ".$cmd;
    }

};


get '/' => sub {
  my $self = shift;
  my $time = strftime "%H:%M", localtime;
  $self->render('index', inittime => $time);
};


get '/command' => sub {
  my $self = shift;
  my $header = $self->req->headers->header('X-Requested-With');
  my $time = strftime "%H:%M", localtime;
  # AJAX request
  if ($header && $header eq 'XMLHttpRequest') {

    my $cmd = $self->param('cmd');
    my $response = parse_cmd($cmd);
      $self->render_json({answer => $response,
			 time => $time});

  }
};


get '/' => sub {
  my $self = shift;
  my $time = strftime "%H:%M", localtime;
  $self->render('index', inittime => $time);
};


app->start;

__DATA__

@@ index.html.ep
  <html>
  <head>
  <title>Kerrigan's home page</title>
  <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.1/jquery.min.js"></script>
  <script type="text/javascript">
  $(document).ready(function() {
      var hist = [];
      var cnt = 0;
      var cn = $("input.console");
      cn.focus();
      // cn.keyup(function(e){
      // 	  var cc = (e.which) ? e.which : e.keyCode
      // 	  if (cc == 38){
      // 	      cn.val(hist[cnt]);
      // 	      if(cnt > 1){ cnt--;}
      // 	  }
      // 	  else if(cc == 40){
      // 	      cn.val(hist[cnt]);
      // 	      if(cnt < 10){cnt++;}
      // 	  }
      // });

      cn.keypress(function(e) {
	  var cc = (e.which) ? e.which : e.keyCode
	  if (cc == 13) {
	      var cmd = cn.val();
	      $.getJSON("/command?cmd=" + cmd, function(json) {
		  if (json.answer) {
		      $("div.terminal").append("<div><span class='tm'>[" +
					       json.time +
					       "]</span><span class='un'>kerrigan</span>@<span class='hn'>aiur%</span> " + 
					       cmd + "</div>" + "<div>" + json.answer + "</div>");
		      if(hist.length >= 10){
			  hist.shift();
		      }
		      hist.push(cmd);
		      cnt = hist.length;
		  } 
		  else {
		      $("#answer").text("Error");
		  }
		  cn.val('');
		  console.log(hist);
                  $('div#ct').html("[" +json.time + "]");
	      });
	  }
      });
  });

</script>
  <style>
  body {
    background-color: black;
    color: white;
    font-family: arial;
  }
  .ct{
  color: #00CCFF;
    }
  input.console{
  border: none;
  outline: none;
  background-color: black;
  color: white;
      width: 800px;
    }
  span.tm {
  color: yellow;
  }
  span.un {
  color: #33FF66;
  }
  span.hn {
  color:#FF6600;
  }
  </style>
  </head>
  <body>
    <div class="terminal">
    <div>Введите help для получения списка команд</div>
  <div><span class='tm'>
      [<%= $inittime %>]</span><span class='un'>kerrigan</span>@<span class='hn'>aiur%</span> uname -a
  <div>
  Linux aiur 2.6.38-10-generic #44-Ubuntu SMP Thu Jun 2 21:32:54 UTC 2011 i686 i686 i386 GNU/Linux</div>
  </div>
  </div>
  <span><span class='tm' id='ct'>
      [<%= $inittime %>]</span>
  <span class='un'>kerrigan</span>@<span class='hn'>aiur% </span>
  </span><input class="console" name="console"/>
  <div id="answer"><%= stash('answer') %></div>
  </body>
  </html>

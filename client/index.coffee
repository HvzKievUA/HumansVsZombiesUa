$ ->
	timer = $('.timer').FlipClock
		countdown: yes
		autoStart: no
	timer.setTime($('.timer').data('timer')/1000)
	timer.start()
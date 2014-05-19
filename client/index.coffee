$ ->
	timer = $('.timer').FlipClock
		countdown: yes
		autoStart: no
	timer.setTime($('.timer').data('timer'))
	timer.start()
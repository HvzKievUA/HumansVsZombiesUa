$.cookie 'mobile', true, { path: '/' }

$ ->
	$('#desktopVersion').on "click touchend", ->
		$.removeCookie('mobile', { path: '/' })
		window.location.href = '/'

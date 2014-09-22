$.cookie 'mobile', true, { path: '/', expires: 365 }

$ ->
	$('#desktopVersion').on "click touchend", ->
		$.removeCookie('mobile', { path: '/' })
		window.location.href = '/'

coffee = require('gulp-coffee')
gulp = require('gulp')
gutil = require('gulp-util')
sourcemaps = require('gulp-sourcemaps')
del = require('del')
nodemon = require('gulp-nodemon')
sass = require('gulp-sass')

paths =
	coffeeClient: './client/js/src/*.coffee'
	jsClient: './client/js/build/'
	sassSrc: './client/css/src/*.scss'
	sassSrcWatch: './client/css/src/**/*.scss'
	cssBuild: './client/css/build/'

gulp.task 'coffee-client', ['clean-js'], ->
	gulp.src(paths.coffeeClient)
		.pipe(sourcemaps.init())
		.pipe(coffee({bare: true}).on('error', gutil.log))
		.pipe(sourcemaps.write('./maps/'))
		.pipe(gulp.dest(paths.jsClient))

gulp.task 'watch', ['coffee-client', 'sass'], ->
	gulp.watch(paths.coffeeClient, ['coffee-client'])
	gulp.watch(paths.sassSrcWatch, ['sass'])

gulp.task 'clean-js', (cb) ->
	del([paths.jsClient], cb)

gulp.task 'clean-css', (cb) ->
	del([paths.cssBuild], cb)

gulp.task 'nodemon', ->
	nodemon(
		script: 'app.coffee'
		ext: 'coffee js'
		watch: ['setup/', 'modules/', 'models/', 'middleware/', 'config/', 'app.coffee']
	).on 'restart', ->
		gutil.log('app restarted')

gulp.task('dev', ['nodemon', 'watch'])
gulp.task('build', ['coffee-client', 'sass'])

gulp.task 'sass', ['clean-css'], ->
	gulp.src(paths.sassSrc)
		.pipe(sass({
			sourceComments: 'map'
		})).on('error', gutil.log)
		.pipe(gulp.dest(paths.cssBuild))

var coffee = require('gulp-coffee');
var gulp = require('gulp');
var gutil = require('gulp-util');
var sourcemaps = require('gulp-sourcemaps');
var del = require('del');
var nodemon = require('gulp-nodemon');
var sass = require('gulp-sass');

paths = {
	coffeeClient: './client/js/src/*.coffee',
	jsClient: './client/js/build/',
	sassSrc: './client/css/src/*.scss',
	sassSrcWatch: './client/css/src/**/*.scss',
	cssBuild: './client/css/build/'
};

gulp.task('coffee-client', ['clean-js'], function() {
	gulp.src(paths.coffeeClient)
		.pipe(sourcemaps.init())
		.pipe(coffee({bare: true}).on('error', gutil.log))
		.pipe(sourcemaps.write('./maps/'))
		.pipe(gulp.dest(paths.jsClient))
});

gulp.task('watch', ['coffee-client', 'sass'], function() {
	gulp.watch(paths.coffeeClient, ['coffee-client']);
	gulp.watch(paths.sassSrcWatch, ['sass']);
});

gulp.task('clean-js', function(cb) {
	del([paths.jsClient], cb);
});

gulp.task('clean-css', function(cb) {
	del([paths.cssBuild], cb);
});

gulp.task('nodemon', function () {
	nodemon({ script: "app.coffee",
		ext: 'coffee js',
		watch: ['setup/', 'modules/', 'models/', 'middleware/', 'config/', 'app.coffee']
	}).on('restart', function () {
		gutil.log('app restarted');
	});
});

gulp.task('dev', ['nodemon', 'watch']);
gulp.task('build', ['coffee-client', 'sass']);

gulp.task('sass', ['clean-css'], function () {
	gulp.src(paths.sassSrc)
		.pipe(sass({
			sourceComments: 'map'
		}))
		.pipe(gulp.dest(paths.cssBuild));
});
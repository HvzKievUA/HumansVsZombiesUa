var coffee = require('gulp-coffee');
var gulp = require('gulp');
var gutil = require('gulp-util');
var sourcemaps = require('gulp-sourcemaps');
var del = require('del');
var nodemon = require('gulp-nodemon')

paths = {
	coffeeClient: './client/js/src/*.coffee',
	jsClient: './client/js/build/'
};

gulp.task('coffee-client', ['clean'], function() {
	gulp.src(paths.coffeeClient)
		.pipe(sourcemaps.init())
		.pipe(coffee({bare: true}).on('error', gutil.log))
		.pipe(sourcemaps.write('./maps/'))
		.pipe(gulp.dest(paths.jsClient))
});

gulp.task('watch', ['coffee-client'], function() {
	gulp.watch(paths.coffeeClient, ['coffee-client']);
});

gulp.task('clean', function(cb) {
	del([paths.jsClient], cb);
});

gulp.task('nodemon', function () {
	nodemon({ script: "app.coffee",
		ext: 'coffee',
		watch: ['setup/', 'modules/', 'models/', 'middleware/', 'config/', 'app.coffee']
	}).on('restart', function () {
		gutil.log('app restarted');
	});
});

gulp.task('dev', ['nodemon', 'watch']);
// plugins for development
var gulp = require('gulp'),
	rimraf = require('rimraf'),
	gulprimraf = require('gulp-rimraf'),
	pug = require('gulp-pug'),
	sass = require('gulp-sass'),
	inlineimage = require('gulp-inline-image'),
	prefix = require('gulp-autoprefixer'),
	plumber = require('gulp-plumber'),
	concat = require('gulp-concat'),
	cssfont64 = require('gulp-cssfont64'),
	sourcemaps = require('gulp-sourcemaps'),
	postcss = require('gulp-postcss'),
	assets = require('postcss-assets'),
	notify = require("gulp-notify"),
	print = require('gulp-print').default,
	rename = require('gulp-rename'),
	replace = require('gulp-replace'),
    debug = require('gulp-debug');

// plugins for build
var purify = require('gulp-purifycss'),
	uglify = require('gulp-uglify-es').default,
	imagemin = require('gulp-imagemin'),
	pngquant = require('imagemin-pngquant'),
	csso = require('gulp-csso');


var assetsDir = 'assets/';
var outputDir = 'dist/';
var buildDir = 'build/';
var productionDir = '../www/assets/';


var resourceCacheDir = '../www/core/cache/resource/';
var pdoToolsCacheDir = '../www/core/cache/default/pdotools/';
var snippetsCacheDir = '../www/core/cache/includes/elements/modsnippet/';
var scriptsCacheDir = '../www/core/cache/scripts/elements/modsnippet/';
var templatesDir = '../www/core/components/gitmodx/elements/templates/';
var snippetsDir = '../www/core/components/gitmodx/elements/snippets/';
var chunksDir = '../www/core/components/gitmodx/elements/chunks/';

//----------------------------------------------------Compiling
gulp.task('pug', function () {
	return gulp.src([assetsDir + 'pug/*.pug', '!' + assetsDir + 'pug/_*.pug'])
		.pipe(plumber())
		.pipe(pug({pretty: true}))
		.on( 'error', notify.onError(
			{
				message: "<%= error.message %>",
				title: "PUG Error!"
			}))
		.pipe(gulp.dest(outputDir));
});

gulp.task('copyToModxTemplates', function () {
	return gulp.src([outputDir + '*.html'])
		.pipe(rename(function (path) {
			path.extname = '.tpl';
			//path.basename += '_new';
		}))
		.pipe(replace(/(src|href)=('|")(i|images|js|styles|fonts)/gi, '$1=$2assets/$3'))
		.pipe(gulp.dest(templatesDir));
});

gulp.task('sass', function () {
	return gulp.src([assetsDir + 'sass/**/*.scss', '!' + assetsDir + 'sass/**/_*.scss'])
		.pipe(plumber())
		.pipe(sourcemaps.init())
		.pipe(sass().on( 'error', notify.onError(
			{
				message: "<%= error.message %>",
				title  : "Sass Error!"
			} ) )
		)
		.pipe(inlineimage())
		.pipe(prefix('last 3 versions'))
		.pipe(postcss([assets({
			basePath:outputDir,
			loadPaths: ['i/']
		})]))
		.pipe(sourcemaps.write())
		.pipe(gulp.dest(productionDir + 'styles/'));
});

gulp.task('jsConcatLibs', function () {
	return gulp.src(assetsDir + 'js/libs/**/*.js')
        .pipe(debug())
		.pipe(concat('libs.js', {newLine: ';'}))
		.pipe(gulp.dest(productionDir + 'js/'));
});

gulp.task('jsConcatComponents', function () {
	return gulp.src(assetsDir + 'js/components/**/*.js')
		.pipe(concat('components.js', {newLine: ';'}))
		.pipe(gulp.dest(productionDir + 'js/'));
});

gulp.task('fontsConvert', function () {
	return gulp.src([assetsDir + 'fonts/*.woff', assetsDir + 'fonts/*.woff2'])
		.pipe(cssfont64())
		.pipe(gulp.dest(productionDir + 'styles/'));
});

//----------------------------------------------------Compiling###

//-------------------------------------------------Synchronization
gulp.task('imageSync', function () {
	return gulp.src(assetsDir + 'i/**/*')
		.pipe(plumber())
		.pipe(gulp.dest(productionDir + 'i/'));
});

gulp.task('fontsSync', function () {
	return gulp.src(assetsDir + 'fonts/**/*')
		.pipe(plumber())
		.pipe(gulp.dest(productionDir + 'fonts/'));
});

gulp.task('jsSync', function () {
	return gulp.src(assetsDir + 'js/*.js')
		.pipe(plumber())
		.pipe(gulp.dest(productionDir + 'js/'));
});
//-------------------------------------------------Synchronization###


//watching files and run tasks
gulp.task('watch', function (done) {
	gulp.watch(assetsDir + 'pug/**/*.pug', gulp.series('pug'));
	gulp.watch(assetsDir + 'sass/**/*.scss', gulp.series('sass'));
	gulp.watch(assetsDir + 'js/**/*.js', gulp.series('jsSync'));
	gulp.watch(assetsDir + 'js/libs/**/*.js', gulp.series('jsConcatLibs'));
	gulp.watch(assetsDir + 'js/components/**/*.js', gulp.series('jsConcatComponents'));
	gulp.watch(assetsDir + 'i/**/*', gulp.series('imageSync'));
	gulp.watch(assetsDir + 'fonts/**/*', gulp.series('fontsSync', 'fontsConvert'));

	gulp.watch(templatesDir + '**/*.tpl', gulp.series('clean-resources-cache','clean-pdotools-cache','clean-snippets-cache'));
	gulp.watch(chunksDir + '**/*.tpl', gulp.series('clean-resources-cache','clean-pdotools-cache','clean-snippets-cache'));
	gulp.watch(snippetsDir + '**/*.php', gulp.series('clean-resources-cache','clean-pdotools-cache','clean-snippets-cache'));
	done();
});


//---------------------------------building final project folder
//clean build folder
gulp.task('cleanBuildDir', function (cb) {
	return rimraf(buildDir, cb);
});

//minify images
gulp.task('imgBuild', function () {
	return gulp.src([outputDir + 'i/**/*', '!' + outputDir + 'i/sprite/**/*'])
		.pipe(imagemin({
			progressive: true,
			svgoPlugins: [{removeViewBox: false}],
			use: [pngquant()]
		}))
		.pipe(gulp.dest(productionDir + 'i/'))
});

//copy sprite.svg
gulp.task('copySprite', function () {
	return gulp.src(outputDir + 'i/sprite/sprite.svg')
		.pipe(plumber())
		.pipe(gulp.dest(productionDir + 'i/sprite/'))
});

//copy and minify js
gulp.task('jsBuild', function () {
	return gulp.src([productionDir + 'js/**/!(*.min)*.js'])
        .pipe(print())
		.pipe(uglify())
		.pipe(rename(function (path) {
			path.extname = '.min.js';
		}))
		.pipe(gulp.dest(productionDir + 'js/'))
});

//copy, minify css
gulp.task('cssBuild', function () {
	return gulp.src([productionDir + 'styles/**/!(*.min)*.css'])
	//.pipe(purify([productionDir + 'js/**/*', outputDir + '**/*.html']))
		.pipe(csso())
		.pipe(rename(function (path) {
			path.extname = '.min.css';
		}))
		.pipe(gulp.dest(productionDir + 'styles/'))
});

// --------------------------------------------If you need svg sprite
var svgSprite = require('gulp-svg-sprite'),
	svgmin = require('gulp-svgmin'),
	cheerio = require('gulp-cheerio');

gulp.task('svgSpriteBuild', function () {
	return gulp.src(assetsDir + 'i/icons/*.svg')
	// minify svg
		.pipe(svgmin({
			js2svg: {
				pretty: true
			}
		}))
		// remove all fill and style declarations in out shapes
		.pipe(cheerio({
			run: function ($) {
				$('[fill]').removeAttr('fill');
				$('[stroke]').removeAttr('stroke');
				$('[style]').removeAttr('style');
			},
			parserOptions: {xmlMode: true}
		}))
		// cheerio plugin create unnecessary string '&gt;', so replace it.
		.pipe(replace('&gt;', '>'))
		// build svg sprite
		.pipe(svgSprite({
			mode: {
				symbol: {
					sprite: "../sprite.svg",
					render: {
						scss: {
							dest:'../../../sass/_sprite.scss',
							template: assetsDir + "sass/templates/_sprite_template.scss"
						}
					},
					example: true
				}
			}
		}))
		.pipe(gulp.dest(assetsDir + 'i/sprite/'));
});

//MODX CLEAN CACHE

gulp.task('clean-resources-cache',function () {
	return gulp.src(resourceCacheDir + '*', {read: false})
		.pipe(gulprimraf({force: true}));
});

gulp.task('clean-pdotools-cache',function(){
	return gulp.src(pdoToolsCacheDir + '**/*.php', {read: false})
		.pipe(gulprimraf({force:true}));
});

gulp.task('clean-snippets-cache',function(){
	return gulp.src(snippetsCacheDir + '*', {read: false})
		.pipe(gulprimraf({force:true})) && gulp.src(scriptsCacheDir + '*', {read: false})
		.pipe(gulprimraf({force:true}));
});


gulp.task('default', gulp.series(gulp.parallel('pug', 'sass', 'imageSync', 'fontsSync', 'fontsConvert', 'jsConcatLibs', 'jsConcatComponents', 'jsSync', 'watch')));

gulp.task('build', gulp.series(
	'cleanBuildDir',
	gulp.parallel('imgBuild', 'jsBuild', 'cssBuild', 'copySprite')
));
// plugins for development
var gulp = require('gulp'),
    gulprimraf = require('gulp-rimraf');

// TODO change paths to yours
var resourceCacheDir = '../www/core/cache/resource/';
var snippetsCacheDir = '../www/core/cache/includes/elements/modsnippet/';
var scriptsCacheDir = '../www/core/cache/scripts/elements/modsnippet/';
var templatesDir = '../www/core/components/gitmodx/elements/templates/';
var snippetsDir = '../www/core/components/gitmodx/elements/snippets/';
var chunksDir = '../www/core/components/gitmodx/elements/chunks/';


//watching files and run tasks
gulp.task('watch', function (done) {
    gulp.watch([templatesDir + '**/*.html',templatesDir + '**/*.tpl'], gulp.series('clean-resources-cache','clean-snippets-cache'));
    gulp.watch(chunksDir + '**/*.tpl', gulp.series('clean-resources-cache','clean-snippets-cache'));
    gulp.watch(snippetsDir + '**/*.php', gulp.series('clean-resources-cache','clean-snippets-cache'));
    done();
});

//MODX CLEAN CACHE

gulp.task('clean-resources-cache',function(){
    return gulp.src(resourceCacheDir + '*', {read: false})
        .pipe(gulprimraf({force:true}));
});

gulp.task('clean-snippets-cache',function(){
    return gulp.src(snippetsCacheDir + '*', {read: false})
        .pipe(gulprimraf({force:true})) && gulp.src(scriptsCacheDir + '*', {read: false})
        .pipe(gulprimraf({force:true}));
});
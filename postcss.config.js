module.exports = {
	plugins: [
		require('postcss-mixins'),
		require('postcss-nested'),
		require('autoprefixer'),
		require('postcss-at-rules-variables')({ atRules: ['media'] })
	]
}

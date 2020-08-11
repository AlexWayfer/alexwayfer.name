module.exports = {
	plugins: [
		require('postcss-nested'),
		require('autoprefixer'),
		require('postcss-at-rules-variables')({ atRules: ['media'] })
	]
}

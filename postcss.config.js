import postcssMixins from 'postcss-mixins'
import postcssNested from 'postcss-nested'
import autoprefixer from 'autoprefixer'
import postcssAtRulesVariables from 'postcss-at-rules-variables'

export default {
	plugins: [
		postcssMixins,
		postcssNested,
		autoprefixer,
		postcssAtRulesVariables({ atRules: ['media'] })
	]
}

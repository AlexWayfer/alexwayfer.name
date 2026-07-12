import globals from 'globals'
import js from '@eslint/js'
import stylistic from '@stylistic/eslint-plugin'

export default [
	js.configs.recommended,
	stylistic.configs.all,
	{
		// files: ['assets/scripts/**/*.js'],
		plugins: {
			'@stylistic': stylistic
		},
		languageOptions: {
			globals: {
				...globals.browser
			}
		},
		rules: {
			'no-var': ['error'],
			'no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
			'no-console': ['warn', { allow: ['error', 'warn'] }],
			'arrow-body-style': ['warn'],

			'@stylistic/indent': ['error', 'tab', { SwitchCase: 1 }],
			'@stylistic/no-mixed-spaces-and-tabs': ['error', 'smart-tabs'],
			'@stylistic/linebreak-style': ['error', 'unix'],
			'@stylistic/max-len': ['error', { code: 100, tabWidth: 2, ignoreUrls: true }],
			'@stylistic/quotes': ['warn', 'single', { avoidEscape: true }],
			'@stylistic/semi': ['error', 'never'],
			'@stylistic/no-multi-spaces': ['error'],
			'@stylistic/keyword-spacing': ['warn', { overrides: { catch: { after: false } } }],
			'@stylistic/brace-style': ['error'],
			'@stylistic/space-before-function-paren': ['warn', 'never'],
			'@stylistic/function-paren-newline': ['warn', 'consistent'],
			'@stylistic/space-before-blocks': ['warn', 'always'],
			'@stylistic/block-spacing': ['warn', 'always'],
			'@stylistic/key-spacing': ['warn'],
			'@stylistic/object-curly-spacing': ['warn', 'always'],
			'@stylistic/space-infix-ops': ['warn'],
			'@stylistic/space-in-parens': ['warn'],
			'@stylistic/arrow-parens': ['warn', 'as-needed'],
			'@stylistic/arrow-spacing': ['warn'],
			'@stylistic/padded-blocks': ['warn', 'never'],
			'@stylistic/spaced-comment': ['warn', 'always', { markers: ['//'] }],
			'@stylistic/multiline-comment-style': ['warn', 'separate-lines'],
			'@stylistic/function-call-argument-newline': ['warn', 'consistent'],
			'@stylistic/quote-props': ['warn', 'as-needed'],
			'@stylistic/object-property-newline': ['warn', { allowAllPropertiesOnSameLine: true }],
			'@stylistic/array-element-newline': ['warn', 'consistent']

			// '@stylistic/dot-location': ['warn', 'property'],
			// '@stylistic/multiline-ternary': ['warn', 'never'],
		}
	},
	{
		files: ['*.config.js'],
		languageOptions: {
			globals: {
				...globals.node
			}
		}
	},
	{
		ignores: [
			'compiled/',
			'assets/scripts/lib/'
		]
	}
]

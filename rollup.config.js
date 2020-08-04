import resolve from '@rollup/plugin-node-resolve'

export default {
	output: {
		format: 'iife',
	},
	plugins: [
		resolve({
			browser: true
		})
	]
}

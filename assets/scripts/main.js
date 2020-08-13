import differenceInYears from 'date-fns/differenceInYears'

document.addEventListener('DOMContentLoaded', () => {
	document.querySelectorAll('.age').forEach(span => {
		span.innerText = differenceInYears(Date.now(), window.birthday)
	})

	const osDarkMode = window.matchMedia('(prefers-color-scheme: dark)').matches

	const savedDarkMode = localStorage.getItem('dark-theme')
	if (savedDarkMode == 'true' || (savedDarkMode === undefined && osDarkMode)) {
		document.body.classList.add('dark-theme')
	}

	document.querySelectorAll('button.theme-toggle').forEach(button => {
		button.addEventListener('click', () => {
			document.body.classList.toggle('dark-theme')

			localStorage.setItem('dark-theme', document.body.classList.contains('dark-theme'))
		})
	})

	window.addEventListener('scroll', () => {
		const
			pageOffset = document.documentElement.scrollTop || document.body.scrollTop,
			threshold = window.innerHeight / 4,
			backToTop = document.querySelector('body > .back-to-top')

		if (pageOffset >= threshold && backToTop.classList.contains('hidden')) {
			backToTop.classList.remove('hidden')
		} else if (pageOffset < threshold && !backToTop.classList.contains('hidden')) {
			backToTop.classList.add('hidden')
		}
	})
})

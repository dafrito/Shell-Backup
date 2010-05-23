function git_push_to_mirrored {
	git push --mirror "$*" 2>&1
}

function git_init_mirrored {
	git init --bare "$*" 2>&1
}

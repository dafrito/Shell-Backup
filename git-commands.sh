function git_push_to_mirrored {
	git push --mirror "$*"
}

function git_init_mirrored {
	git init --bare "$*"
}

export default {
  player (login) {
    return `/player/${login}`;
  },
  upic (login, type) {
    return `/api/user/${login}/pic?s=${type}`;
  },
};

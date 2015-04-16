#include <errno.h>
#include <stdio.h>

#include <string>

#include <eval-inline.hh>
#include <eval.hh>
#include <store-api.hh>
#include <util.hh>

#include <gpgme.h>

static inline void
fail_if_err (const gpgme_error_t & err)
{
  if (err)
    {
      fprintf (stderr, "%s:%d: %s: %s\n",
               __FILE__, __LINE__, gpgme_strsource (err),
               gpgme_strerror (err));
      exit (EXIT_FAILURE);
    }
}

static std::string
gpgme_decrypt (const std::string &path)
{
  gpgme_ctx_t ctx;
  gpgme_error_t err;
  gpgme_data_t in, out;
  gpgme_decrypt_result_t result;
  std::string res;
  int ret;

  const size_t BUF_SIZE = 512;
  char buf[BUF_SIZE + 1];

  gpgme_check_version (NULL);
  err = gpgme_new (&ctx);
  fail_if_err (err);

  err = gpgme_data_new_from_file (&in, path.c_str(), 1);
  fail_if_err (err);

  err = gpgme_data_new (&out);
  fail_if_err (err);

  err = gpgme_op_decrypt (ctx, in, out);
  fail_if_err (err);

  result = gpgme_op_decrypt_result (ctx);
  if (result->unsupported_algorithm)
    {
      fprintf (stderr, "%s:%i: unsupported algorithm: %s\n",
               __FILE__, __LINE__, result->unsupported_algorithm);
      exit (EXIT_FAILURE);
    }

  ret = gpgme_data_seek (out, 0, SEEK_SET);
  if (ret)
    fail_if_err (gpgme_err_code_from_errno (errno));
  while ((ret = gpgme_data_read (out, buf, BUF_SIZE)) > 0)
    res.append (buf, ret);
  if (ret < 0)
    fail_if_err (gpgme_err_code_from_errno (errno));

  gpgme_data_release (in);
  gpgme_data_release (out);
  gpgme_release (ctx);

  return (res);
}



extern "C" void decrypt( nix::EvalState & state
                       , const nix::Pos & pos
                       , nix::Value ** args
                       , nix::Value & v
                       ) {
  state.forceValue(*args[0]);

  auto name = state.forceStringNoCtx(*args[1], pos);

  auto ctx = nix::PathSet{};
  auto path = state.coerceToPath(pos, *args[2], ctx);
  nix::realiseContext(ctx);

  fprintf (stderr, "Decrypting `%s'\n", path.c_str());
  auto contents = gpgme_decrypt (path);
  auto res = nix::store->addTextToStore (name, contents, nix::PathSet{});

  nix::mkString(v, res, nix::PathSet{res});
}


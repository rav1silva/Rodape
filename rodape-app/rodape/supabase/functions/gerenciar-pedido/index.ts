
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

const json = (body: unknown, status = 200) =>
  Response.json(body, {
    status,
    headers: { "Content-Type": "application/json" },
  });

export default {
  fetch: withSupabase(
    { auth: ["publishable", "secret"] },
    async (req, ctx) => {
      if (req.method !== "POST") {
        return json({ erro: "Método não permitido." }, 405);
      }

      try {
        const body = await req.json();
        const acao = body?.acao;
        const pedidoId = body?.pedido_id;

        if (
          typeof acao !== "string" ||
          typeof pedidoId !== "string" ||
          !pedidoId.trim()
        ) {
          return json(
            { erro: "Informe uma ação e um ID de pedido válidos." },
            400,
          );
        }

        const acoesPermitidas = [
          "aceitar",
          "recusar",
          "enviar",
          "confirmar_entrega",
        ];

        if (!acoesPermitidas.includes(acao)) {
          return json({ erro: "Ação não reconhecida." }, 400);
        }

        // Nenhuma alteração é permitida enquanto a identidade
        // do usuário não puder ser comprovada.
        if (ctx.authMode !== "secret") {
          return json(
            {
              erro:
                "Autenticação real necessária antes de alterar pedidos.",
            },
            401,
          );
        }

        return json({
          mensagem: "Dados validados. Próxima etapa: autorização e operação.",
          acao,
          pedido_id: pedidoId,
        });
      } catch {
        return json({ erro: "Requisição inválida." }, 400);
      }
    },
  ),
};

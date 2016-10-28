"""Add column winning rate

Revision ID: 232c9d758365
Revises: 464ce480fa8
Create Date: 2015-08-11 10:34:46.159000

"""

# revision identifiers, used by Alembic.
revision = '232c9d758365'
down_revision = '464ce480fa8'
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('stockSignal', sa.Column('win_rate', sa.FLOAT))
    pass


def downgrade():
    op.drop_column('stockSignal', sa.Column('win_rate', sa.FLOAT))
    pass
